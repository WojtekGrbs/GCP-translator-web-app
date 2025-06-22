
# [Translator Web Application](https://micro-eye-455517-a2.web.app/dashboard.html)
Authors: [Natalia Safiejko](https://github.com/ssafiejko), [Wojciech Grabias](https://github.com/WojtekGrbs)

*Currently translation service is disabled due to insufficient funds on the GCP account* <br>

A modular [web app](https://micro-eye-455517-a2.web.app/dashboard.html) for multilingual translation with profanity filtering and per-user quota management, deployed on Google Cloud.

<br>
<img width="1375" alt="Screenshot 2025-06-22 at 14 03 17" src="https://github.com/user-attachments/assets/ca79f164-b12b-45d7-9c2a-3ecbb497f64d" />

## Features


- **Firebase Authentication** (email + password)
- **Profanity detection** (ibm-granite/granite-guardian-hap-38m)
- **Translation** (google-t5/t5-small): English → French, German, Romanian, Spanish
- **Quota enforcement** (Redis, 100 translations/day)
- **Data storage:** Firestore (operational), Postgres (analytics)
- **Microservices:** Cloud Run (Flask + FastAPI), Cloud Function, API Gateway

## Architecture

```plaintext
User → Frontend (ID Token) → API Gateway → Cloud Function
 ├── Redis (quota check)
 ├── Profanity service (Cloud Run, Flask)
 ├── Translation service (Cloud Run, FastAPI)
 └── Firestore (save history)
Nightly: Firestore → PostgreSQL
```

## API Overview

### Profanity API (Flask)

- `POST /check_profanity` → `{ is_toxic: bool, probability: float }`
- `GET /health` → `{ status: "ok" }`

### Translation API (FastAPI)

- `POST /generate` → `{ generated_text: str, language: str }`
- `GET /` → health check

## Storage

- **Firestore:** User profiles, translation history
- **Postgres:** Analytics warehouse (daily batch)
- **Redis:** Daily quota (userId: count, TTL 24h)

## SLOs

| Metric | Target |
|---------|---------|
| Availability (API / Cloud Run) | 99.9%+ |
| P95 latency (no cold start) | < 1s |
| Cold start P99 | < 15s |
| Error rate | < 1.5% |
| Redis latency P95 | < 10ms |
| BLEU score | > 0.3 |
| Profanity accuracy | > 0.85 |

## Deployment

- **Cloud Run:** Profanity + translation services (Docker)
- **Cloud Function:** Business logic
- **Cloud SQL:** Analytics
- **Firestore + Redis:** Operational data

## Monitoring

- GCP Monitoring / Trace for latency, availability, errors
- BLEU + accuracy sampling for model quality

## Repo

👉 [Source](https://github.com/WojtekGrbs/translator-web-app)

## License

MIT License
