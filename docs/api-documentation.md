# API Documentation

## Source of Truth
- OpenAPI contract: `packages/contracts/survey-backend.openapi.yaml`
- Generated SDKs: `packages/contracts/generated/dart` and `packages/contracts/generated/python`

## Base URL
- Local default: `http://localhost:8000/api/v1`
- All endpoints use JSON payloads and responses.

## Endpoints
- **Surveys**
  - `POST /surveys/` – create survey (body: `Survey`); returns created survey.
  - `GET /surveys/` – list all surveys.
  - `GET /surveys/{survey_id}` – fetch survey by id.

- **Survey Responses**
  - `POST /survey_responses/` – create survey response; persists, triggers email background task, optionally enriches with Clinical Writer. Returns `SurveyResponseWithAgent`.
  - `GET /survey_responses/` – list all survey responses.
  - `GET /survey_responses/{response_id}` – fetch a survey response by id (400 on bad ObjectId, 404 if missing).
  - `POST /survey_responses/{response_id}/send_email` – enqueue an email re-send for an existing response (202 Accepted on success).

- **Patient Responses**
  - `POST /patient_responses/` – create patient-facing response; same enrichment flow as survey responses. Returns `SurveyResponseWithAgent`.

## Models (abridged)
- `Survey`: survey metadata and questions, stored in MongoDB.
- `SurveyResponse`: answers plus patient details.
- `AgentResponse`: AI payload with `classification`, `medical_record` (`medicalRecord` in payload), and optional `error_message` (`errorMessage`).
- `SurveyResponseWithAgent`: response payload plus optional `agent_response`.

## Error Semantics
- `400` for validation errors (e.g., malformed ObjectId).
- `404` for missing resources.
- `500` for unexpected server errors.

## Usage Guidance
- Prefer SDKs generated from the OpenAPI contract over ad-hoc HTTP calls.
- Clients should not attempt direct MongoDB or Clinical Writer access; all interactions go through the backend or worker.
