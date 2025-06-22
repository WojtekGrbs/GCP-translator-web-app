from firebase_functions import https_fn, options
from firebase_admin import initialize_app, credentials, auth, firestore
import firebase_admin
import os
import json
import requests
from google.auth.transport.requests import Request
from google.auth import default as google_auth_default
from google.auth.compute_engine import IDTokenCredentials
import redis

# Firebase Admin initialization
if not firebase_admin._apps:
    cred = credentials.ApplicationDefault()
    firebase_admin.initialize_app(cred)

# Google credentials for ID token generation
google_creds, _ = google_auth_default()
auth_request = Request()

def generate_id_token(audience_url):
    request = Request()
    creds = IDTokenCredentials(request=request, target_audience=audience_url)
    creds.refresh(request)
    return creds.token

# ENV vars
PROJECT_ID             = os.getenv('PROJECT_ID')
PROFANITY_SERVICE_URL  = os.getenv('PROFANITY_SERVICE_URL') + '/check_profanity'
TRANSLATOR_SERVICE_URL = os.getenv('TRANSLATOR_SERVICE_URL') + '/generate'
REDIS_HOST             = os.getenv('REDIS_HOST')
REDIS_PORT             = os.getenv('REDIS_PORT')
REDIS_PASSWORD         = os.getenv('REDIS_PASSWORD', None)
QUOTA_LIMIT            = int(os.getenv('REDIS_QUOTA'))
QUOTA_TTL              = 86400

firestore_db = firestore.client()

@https_fn.on_request(
    cors=options.CorsOptions(
        cors_origins="*",
        cors_methods=["post", "options", "get"],
    )
)
def handler(req: https_fn.Request) -> https_fn.Response:
    # Extract Firebase user from token
    auth_header = req.headers.get("X-Forwarded-Authorization", "")
    if not auth_header.startswith('Bearer '):
        return https_fn.Response(json.dumps({"error": "Missing Authorization header"}), status=401)

    try:
        id_token = auth_header.split('Bearer ')[1]
        decoded_token = auth.verify_id_token(id_token)
        uid = decoded_token['uid']
    except Exception as e:
        return https_fn.Response(json.dumps({"error": f"Token verification failed: {str(e)}"}), status=401)

    # Redis quota handling
    redis_client = redis.Redis(
        host=REDIS_HOST, port=REDIS_PORT, password=REDIS_PASSWORD, decode_responses=True
    )

    try:
        key = f"quota:{uid}"
        quota_remaining = redis_client.get(key)
        if quota_remaining is None:
            quota_remaining = QUOTA_LIMIT - 1
            redis_client.set(key, quota_remaining, ex=QUOTA_TTL)
        else:
            quota_remaining = int(quota_remaining)
            if quota_remaining <= 0:
                return https_fn.Response(
                    json.dumps({"success": False, "message": "Daily quota exceeded."}), status=403
                )
            quota_remaining = redis_client.decr(key)
    except Exception as e:
        return https_fn.Response(json.dumps({"error": f"Redis error: {str(e)}"}), status=500)
    finally:
        redis_client.quit()

    # CORS & method check
    cors_headers = {
        "Access-Control-Allow-Origin": f"https://{PROJECT_ID}.web.app",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }
    if req.method == "OPTIONS":
        return https_fn.Response("", status=204, headers=cors_headers)
    if req.method != "POST":
        return https_fn.Response(json.dumps({"error": "Method not allowed"}), status=405)

    try:
        data = req.get_json()
        original_text = data.get('text')
        language_code = data.get('language_code', 'en')
        if not original_text:
            return https_fn.Response(json.dumps({"error": "Missing 'text' in request."}), status=400)
    except Exception:
        return https_fn.Response(json.dumps({"error": "Invalid JSON"}), status=400)

    #################### PROFANITY CHECK ####################
    try:
        profanity_token = generate_id_token(PROFANITY_SERVICE_URL)
        print(profanity_token)
        profanity_response = requests.post(PROFANITY_SERVICE_URL,
                                           json={"text": original_text},
                                           headers={"Authorization": f"Bearer {profanity_token}"})
        profanity_result = profanity_response.json()
        is_toxic = profanity_result.get('is_toxic', True)
        toxicity_probability = profanity_result.get('probability', 0.0)

        if is_toxic:
            firestore_db.collection("translations") \
                .document(uid).collection("logs").add({
                    "uid": uid,
                    "original_text": original_text,
                    "translated_text": None,
                    "language_code": language_code,
                    "quota_remaining": quota_remaining,
                    "toxic_probability": toxicity_probability,
                    "is_toxic": is_toxic,
                    "created_at": firestore.SERVER_TIMESTAMP
                })
            return https_fn.Response(
                json.dumps({"success": False, "message": profanity_result.get('message', 'Text contains prohibited content.')}),
                status=403
            )
    except Exception as e:
        return https_fn.Response(json.dumps({"error": f"Profanity service error: {str(e)}"}), status=500)

    #################### TRANSLATION ########################
    try:
        translation_token = generate_id_token(TRANSLATOR_SERVICE_URL)
        translation_response = requests.post(TRANSLATOR_SERVICE_URL,
                                             json={"prompt": original_text, "language": language_code},
                                             headers={"Authorization": f"Bearer {translation_token}"})
        translation_result = translation_response.json()
        translated_text = translation_result.get('generated_text')
    except Exception as e:
        return https_fn.Response(json.dumps({"error": f"Translation service error: {str(e)}"}), status=500)
    
    #################### FIREBASE ####################
    try:
        doc_ref = firestore_db.collection("translations") \
                    .document(uid) \
                    .collection("logs") \
                    .add({
            "uid": uid,
            "original_text": original_text,
            "translated_text": translated_text,
            "language_code": language_code,
            "quota_remaining": quota_remaining,
            "toxic_probability": toxicity_probability, 
            "is_toxic": is_toxic,
            "created_at": firestore.SERVER_TIMESTAMP
        }) 
    except Exception as e:
        return https_fn.Response(
            json.dumps({"error": f"Firestore write failed: {e}"}),
            status=500
        )
    #################### RESPONSE GENERATION ####################
    response_payload = {
        "success": True,
        "original_text": original_text,
        "translated_text": translated_text,
        "language_code": language_code
    }
    return https_fn.Response(
        json.dumps(response_payload),
        status=200
    )
