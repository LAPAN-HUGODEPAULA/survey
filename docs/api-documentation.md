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

- **Survey Responses**
  - `POST /survey_responses/` – create survey response; persists, triggers email background task, optionally enriches with Clinical Writer. Returns `SurveyResponseWithAgent`.
  - `GET /survey_responses/` – list all survey responses.
  - `GET /survey_responses/{response_id}` – fetch a survey response by id (400 on bad ObjectId, 404 if missing).
  - `POST /survey_responses/{response_id}/send_email` – enqueue an email re-send for an existing response (202 Accepted on success).

- **Patient Responses**
  - `POST /patient_responses/` – create patient-facing response; same enrichment flow as survey responses. Returns `SurveyResponseWithAgent`.
  - `POST /clinical_writer/process` – backend proxy to Clinical Writer `/process` with JSON-only report output.

## Models (abridged)

- `SurveyPrompt`: questionnaire prompt definition stored canonically in `QuestionnairePrompts`.
- `PersonaSkill`: output-profile persona definition stored in `PersonaSkills`.
- `Survey`: survey metadata and questions, stored in the `surveys` collection with an embedded `prompt` reference (`promptKey`, `name`).
- `SurveyResponse`: answers plus patient details, stored in the `survey_responses` collection, with optional `personaSkillKey` and `outputProfile`.
- `PatientResponse`: answers plus patient details, stored in the `patient_responses` collection.
- `AgentResponse`: AI payload with `ok`, `input_type`, `prompt_version`, `questionnaire_prompt_version`, `persona_skill_version`, `model_version`, `report`, `warnings`.
- `SurveyResponseWithAgent`: response payload plus optional `agent_response`.

## Clinical Writer Contract (/clinical_writer/process)

Request body (JSON):

- `input_type`: `consult` | `survey7` | `full_intake`
- `content`: raw consult text or JSON string payload
- `locale`: defaults to `pt-BR`
- `prompt_key`: defaults to `default`
- `persona_skill_key`: optional persona key for output tone/restrictions
- `output_profile`: optional output profile used to derive a default persona skill
- `output_format`: must be `report_json`
- `metadata`: `source_app`, `request_id`, `patient_ref` (optional)
  - `patient_ref` should be treated as an opaque correlation identifier.
    Backend integrations may pseudonymize it before persistence.

Response body (JSON):

- `ok`: boolean
- `input_type`: echoes request input type
- `prompt_version`: composite runtime prompt version
- `questionnaire_prompt_version`: questionnaire prompt document version used for the request
- `persona_skill_version`: persona skill document version used for the request
- `model_version`: model used for generation
- `report`: structured JSON ReportDocument (no markdown)
- `warnings`: list of warnings (empty when successful)

Samples:

- Inputs: `samples/clinical-writer/inputs/*.json`
- Outputs: `samples/clinical-writer/outputs/*.json`

## Error Semantics

- `400` for validation errors (e.g., malformed ObjectId).
- `404` for missing resources.
- `500` for unexpected server errors.

## Security Notes

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
- Screener password recovery uses the same SMTP/FastMail configuration as survey and patient response emails (`SMTP_*` or `MAIL_*` environment variables).
- On a fresh local database migrated with `tools/migrations/survey-backend/003_populate_new_schema.py`, the seeded screeners are `lapan.hugodepaula@gmail.com` / `SystemPassword123!` and `maria.vale@holhos.com` / `SamplePassword123!` until those passwords are changed or recovered.
- If an older database still uses `survey_results` or `patient_results`, run `tools/migrations/survey-backend/004_rename_response_collections.py` to move it to the canonical `survey_responses` and `patient_responses` collections.
