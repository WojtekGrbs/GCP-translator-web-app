import requests
import json

BEARER = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjcxMTE1MjM1YTZjNjE0NTRlZmRlZGM0NWE3N2U0MzUxMzY3ZWViZTAiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbWljcm8tZXllLTQ1NTUxNy1hMiIsImF1ZCI6Im1pY3JvLWV5ZS00NTU1MTctYTIiLCJhdXRoX3RpbWUiOjE3NDQwMzA4MDYsInVzZXJfaWQiOiJwZE16U2dTVlpxVk5uU2l4UmRjTHJ4Sm5sT3oyIiwic3ViIjoicGRNelNnU1ZacVZOblNpeFJkY0xyeEpubE96MiIsImlhdCI6MTc0NDAzMDgwNiwiZXhwIjoxNzQ0MDM0NDA2LCJlbWFpbCI6ImFiY0BnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZW1haWwiOlsiYWJjQGdtYWlsLmNvbSJdfSwic2lnbl9pbl9wcm92aWRlciI6InBhc3N3b3JkIn19.HvQZiB_74oJ6TE2Mchir8WOS5SAjuqDaYcJda42pANRZM1P0r_2-H8wk1AlC612oBry1WE1Pn-8HaLsIj7jaNsR83wfDBfKsiphcmalj0Furm-qZsz_hPzda4ziB_cRY07ySoOAngCQxLwu2hDml-7woo0RiVA35GszogfAR36T2n3hUEBze0mNvpm8dqsb0LOhr3QcbbbvysY-GgLXtejkhk6orfLB8OgO62ATkhSa9r2SvUjE3hHYD1HFmDM8Mepq2zMbBrD2OpHEisx7-YRZ9Utcds9j7QeHL20kkFQZdgEsC8uyJdecfKu-MfsXiOO3TNRxyspgLLzzYsR6k8Q"
url = "https://profanity-filter-4d6jq3gyhq-ew.a.run.app/check_profanity"  # Replace with your actual API host

# headers = {
#     "Origin": "https://micro-eye-455517-a2.web.app",
#     "Access-Control-Request-Method": "POST",
#     "Access-Control-Request-Headers": "Content-Type"
# }

body = {
  "text": "testing",
}
response = requests.post(url, json=body)
print(response.json().get("is_toxic", True))
# Print out response details
print("Status Code:", response.status_code)
print("Headers:")
for key, value in response.headers.items():
    print(f"  {key}: {value}")
print("Body:", response.text)




