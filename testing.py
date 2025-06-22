import requests
import json

def verify_cloud_function(project_id="micro-eye-455517-a2", region="europe-west3", function_name="translation-orchestrator"):
    """
    Verify if the Cloud Function works properly by testing CORS and functionality.
    
    Args:
        project_id (str): Your Firebase project ID (e.g., 'micro-eye-455517-a2').
        region (str): The region where the function is deployed (e.g., 'europe-west3').
        function_name (str): The name of the Cloud Function (e.g., 'translation-orchestrator').
    
    Returns:
        bool: True if the function works as expected, False otherwise.
    """
    base_url = f"https://translator-gateway-bj8a1opm.nw.gateway.dev/translate"
    origin = f"https://{project_id}.web.app"
    headers = {
        "Origin": origin,
        "Content-Type": "application/json",
    }
    
    # Step 1: Test CORS preflight (OPTIONS request)
    print("Testing CORS preflight (OPTIONS request)...")
    preflight_headers = {
        "Origin": origin,
        "Access-Control-Request-Method": "POST",
        "Access-Control-Request-Headers": "Content-Type",
    }
    try:
        response = requests.options(base_url, headers=preflight_headers, timeout=5)
        print(f"Status Code: {response.status_code}")
        print(f"Headers: {json.dumps(dict(response.headers), indent=2)}")
        
        # Check if CORS headers are present
        cors_headers = {
            "Access-Control-Allow-Origin": origin,
            "Access-Control-Allow-Methods": "POST, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type",
        }
        for header, expected_value in cors_headers.items():
            actual_value = response.headers.get(header)
            if actual_value != expected_value:
                print(f"ERROR: Expected {header} to be '{expected_value}', got '{actual_value}'")
                return False
        if response.status_code != 204:
            print(f"ERROR: Expected status 204 for OPTIONS, got {response.status_code}")
            return False
        print("CORS preflight test passed!")
    except requests.RequestException as e:
        print(f"ERROR: OPTIONS request failed: {str(e)}")
        return False

    # Step 2: Test POST request with sample data
    print("\nTesting POST request...")
    payload = {
        "text": "Hello, world!",
        "language_code": "es"
    }
    try:
        response = requests.post(base_url, headers=headers, json=payload, timeout=10)
        print(f"Status Code: {response.status_code}")
        print(f"Headers: {json.dumps(dict(response.headers), indent=2)}")
        print(f"Body: {response.text}")
        
        # Check response
        if response.status_code != 200:
            print(f"ERROR: Expected status 200, got {response.status_code}")
            return False
        
        response_json = response.json()
        if not response_json.get("success", False):
            print(f"ERROR: Response indicates failure: {response_json}")
            return False
        
        if response_json.get("translated_text") is None:
            print("ERROR: No translated_text in response")
            return False
        
        # Check CORS header in POST response
        if response.headers.get("Access-Control-Allow-Origin") != origin:
            print(f"ERROR: Expected Access-Control-Allow-Origin '{origin}', got '{response.headers.get('Access-Control-Allow-Origin')}'")
            return False
        
        print("POST request test passed!")
    except requests.RequestException as e:
        print(f"ERROR: POST request failed: {str(e)}")
        return False
    except ValueError as e:
        print(f"ERROR: Invalid JSON response: {str(e)}")
        return False

    print("\nAll tests passed! Cloud Function is working properly.")
    return True

# Run the verification
if __name__ == "__main__":
    result = verify_cloud_function()
    print(f"Verification result: {result}")