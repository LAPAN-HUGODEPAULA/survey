# API Documentation

## Source of Truth

- OpenAPI contract: `packages/contracts/survey-backend.openapi.yaml`
- Generated SDKs: `packages/contracts/generated/dart` and `packages/contracts/generated/python`

## Base URL

- Local default: `http://localhost:8000/api/v1`
- All endpoints use JSON payloads and responses.
- Browser clients must originate from an allowlisted origin when CORS is
  enabled with credentials.

## Endpoints

- **Screeners**
  - `POST /screeners/register` - create a screener account.
  - `POST /screeners/login` - authenticate a screener and return a bearer token.
  - `GET /screeners/me` - return the authenticated screener profile.
  - `POST /screeners/recover-password` - generate a new random password and email it to the screener when SMTP is configured. Returns a generic success message even when the email is unknown.

- **Surveys**
  - `POST /surveys/` – create survey (body: `Survey`); returns created survey.
  - `GET /surveys/` – list all surveys.
  - `GET /surveys/{survey_id}` – fetch survey by id.

- **Survey Prompts**
  - `GET /survey_prompts/` – list questionnaire prompt definitions backed by the canonical `QuestionnairePrompts` collection.
  - `POST /survey_prompts/` – create a questionnaire prompt definition.
  - `GET /survey_prompts/{prompt_key}` – fetch a reusable prompt by key.
  - `PUT /survey_prompts/{prompt_key}` – update a reusable prompt definition.
  - `DELETE /survey_prompts/{prompt_key}` – delete an unused prompt definition.

- **Persona Skills**
  - `GET /persona_skills/` – list persona skill definitions from the `PersonaSkills` collection.
  - `POST /persona_skills/` – create a persona skill definition.
  - `GET /persona_skills/{persona_skill_key}` – fetch a persona skill by key.
  - `PUT /persona_skills/{persona_skill_key}` – update a persona skill definition.
  - `DELETE /persona_skills/{persona_skill_key}` – delete a persona skill definition.

- **Agent Access Points**
  - `GET /agent_access_points/` - list access-point definitions that bind runtime entry points to prompt, persona, and output-profile selections.
  - `POST /agent_access_points/` - create an access-point definition with referential validation against surveys, questionnaire prompts, persona skills, and output profiles.
  - `GET /agent_access_points/{access_point_key}` - fetch one access point by stable key.
  - `PUT /agent_access_points/{access_point_key}` - update an access-point definition.
  - `DELETE /agent_access_points/{access_point_key}` - delete an access-point definition.

- **Survey Responses**
  - `POST /survey_responses/` – create survey response; persists, triggers email background task, resolves runtime configuration through request overrides, access point, survey defaults, and legacy fallback, then optionally enriches with one or more Clinical Writer artifacts. Returns `SurveyResponseWithAgent`.
  - `GET /survey_responses/` – list all survey responses.
  - `GET /survey_responses/{response_id}` – fetch a survey response by id (400 on bad ObjectId, 404 if missing).
  - `POST /survey_responses/{response_id}/send_email` – enqueue an email re-send for an existing response (202 Accepted on success).

- **Patient Responses**
  - `POST /patient_responses/` – create patient-facing response; same access-point resolution and multi-artifact enrichment flow as survey responses. Returns `SurveyResponseWithAgent`.
  - `POST /clinical_writer/process` – backend proxy to Clinical Writer `/process` with JSON-only report output.

## Models (abridged)

- `SurveyPrompt`: questionnaire prompt definition stored canonically in `QuestionnairePrompts`.
- `PersonaSkill`: output-profile persona definition stored in `PersonaSkills`.
- `Survey`: survey metadata and questions, stored in the `surveys` collection with an embedded `prompt` reference (`promptKey`, `name`).
- `AgentAccessPoint`: builder-managed runtime mapping with `accessPointKey`, `sourceApp`, `flowKey`, optional `surveyId`, and bound `promptKey`, `personaSkillKey`, and `outputProfile`.
- `SurveyResponse`: answers plus patient details, stored in the `survey_responses` collection, with optional `accessPointKey`, `promptKey`, `personaSkillKey`, and `outputProfile`.
- `PatientResponse`: answers plus patient details, stored in the `patient_responses` collection.
- `SurveyResponseWithAgent`: response payload plus a legacy-compatible `agentResponse` field and the full `agentResponses` list for access-point fan-out results.
- `ApiError`: standardized frontend-safe error object with `code`, `userMessage`, `severity`, `retryable`, `requestId`, and optional `details`.

## Clinical Writer Contract (/clinical_writer/process)

The Clinical Writer API supports both synchronous and asynchronous processing. For long-running report generation, **asynchronous mode is preferred** and enabled by default in backend proxies.

Request body (JSON):

- `input_type`: `consult` | `survey7` | `full_intake`
- `content`: raw consult text or JSON string payload
- `locale`: defaults to `pt-BR`
- `accessPointKey`: optional stable runtime entry-point identifier. When supplied, the backend requires `surveyId` in `metadata` or encoded in the JSON `content`.
- `prompt_key`: defaults to `default`
- `persona_skill_key`: optional persona key for output tone/restrictions
- `output_profile`: optional output profile used to derive a default persona skill
- `output_format`: must be `report_json`
- `async_mode`: boolean, defaults to `true` in proxies. When true, returns `202 Accepted` or a task status object immediately.
- `metadata`: `source_app`, `request_id`, `patient_ref`, and optional `surveyId` / `survey_id`

Response body (Synchronous or Polling Result):

- `ok`: boolean
- `report`: structured JSON ReportDocument
- `ai_progress`: object containing `stage`, `stageLabel`, `userMessage`, and `status`.

Asynchronous Status (/clinical_writer/status/{task_id}):

- `taskId`: unique job identifier.
- `status`: `submitted` | `processing` | `completed` | `failed`.
- `aiProgress`: current stage information for wayfinding.
- `result`: the generated report (only when status is `completed`).
- `error`: structured error details (only when status is `failed`).

## Runtime Precedence

Survey-driven Clinical Writer resolution now follows this order:

1. Explicit request overrides: `promptKey`, `personaSkillKey`, `outputProfile`
2. Access-point bindings resolved from `accessPointKey`
3. Survey defaults stored on the survey document
4. Legacy fallback from the historical prompt-selection path for non-migrated flows

For survey completion endpoints, the backend may fan out to multiple access points for the same `sourceApp`, `flowKey`, and `surveyId`. The first artifact is mirrored into `agentResponse` for backward compatibility, and every generated artifact is returned in `agentResponses`.

## Error Semantics

All non-2xx responses from the platform APIs return a standardized `ApiError` object.

- **Standard Status Codes:**
  - `400 Bad Request`: Validation errors or malformed identifiers (`code: VALIDATION_FAILED`).
  - `401 Unauthorized`: Missing or invalid credentials (`code: UNAUTHORIZED`).
  - `403 Forbidden`: Insufficient permissions or expired links (`code: FORBIDDEN` or `code: LINK_EXPIRED`).
  - `404 Not Found`: Resource not found (`code: NOT_FOUND`).
  - `500 Internal Server Error`: Unexpected backend failure (`code: INTERNAL_SERVER_ERROR`).

- **Recovery Fields:**
  - `userMessage`: human-readable guidance in Brazilian Portuguese.
  - `retryable`: boolean indicating if the client should attempt the request again.
  - `requestId`: correlation ID for log investigation.

- `survey-backend` enforces HTTPS in production and emits browser hardening
  headers on responses.
- `clinical-writer-api` protected endpoints require
  `Authorization: Bearer <token>` when `API_TOKEN` is configured.
- In production, `clinical-writer-api` must not run without `API_TOKEN`
  unless `ALLOW_UNAUTHENTICATED_ACCESS=true` is set intentionally for a
  controlled environment.

## Usage Guidance

- Prefer SDKs generated from the OpenAPI contract over ad-hoc HTTP calls.
- Clients should not attempt direct MongoDB or Clinical Writer access; all interactions go through the backend or worker.
- Use access-point keys for survey-driven entry points instead of hard-coding prompt assumptions in clients. The current default thank-you keys are `survey_patient.thank_you.auto_analysis` and `survey_frontend.thank_you.auto_analysis`.
- Screener password recovery uses the same SMTP/FastMail configuration as survey and patient response emails (`SMTP_*` or `MAIL_*` environment variables).
- On a fresh local database migrated with `tools/migrations/survey-backend/003_populate_new_schema.py`, the seeded screeners are `lapan.hugodepaula@gmail.com` / `SystemPassword123!` and `maria.vale@holhos.com` / `SamplePassword123!` until those passwords are changed or recovered.
- If an older database still uses `survey_results` or `patient_results`, run `tools/migrations/survey-backend/004_rename_response_collections.py` to move it to the canonical `survey_responses` and `patient_responses` collections.
- For rollout sequencing and fallback guidance, follow [access-point-runtime.md](/home/hugo/Documents/LAPAN/dev/survey/docs/runbooks/access-point-runtime.md).
