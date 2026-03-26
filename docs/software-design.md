# Software Design Document

## Architecture Overview

- Monorepo organized into `services/`, `apps/`, `packages/`, and `tools/`.
- Backend is FastAPI with repositories for MongoDB access; integrations cover email and Clinical Writer calls.
- Worker processes augment survey responses asynchronously.
- Clinical Writer API is an external-but-co-located FastAPI + LangGraph service using configurable agents.
- Flutter web apps consume generated SDKs and the shared design system for a consistent experience.

## Backend Design (`services/survey-backend`)

- **Entry point**: `app/main.py` wires CORS, routers, lifecycle logging, and an HTTPS-only guard when `ENVIRONMENT=production`.
- **Routing**: `/api/v1/survey_prompts`, `/api/v1/surveys`, `/api/v1/survey_responses`, `/api/v1/patient_responses` plus `/survey_responses/{id}/send_email` for re-sends.
- **Screener auth**: `/api/v1/screeners/register`, `/api/v1/screeners/login`, `/api/v1/screeners/me`, and `/api/v1/screeners/recover-password` support screener registration, authentication, profile lookup, and password recovery.
- **Domain models**: `app/domain/models/*` define Pydantic schemas for surveys, reusable prompts, patients, and agent responses.
- **Survey schema**: surveys stored in MongoDB now embed a compact `prompt` reference while the reusable prompt definitions themselves live in the `survey_prompts` collection.
- **Persistence**: repositories under `app/persistence/repositories` encapsulate MongoDB CRUD; injected via `app.persistence.deps` to keep handlers decoupled from storage.
- **Integrations**:
  - `app.integrations.clinical_writer.client` submits responses for AI enrichment.
  - `app.integrations.email.service` dispatches response emails using FastAPI `BackgroundTasks` and exposes the shared `FastMail` client used by screener password recovery.
- **Error handling**: routers translate validation errors into HTTP 400/404, unexpected issues into 500s with structured logs.

## Worker Design (`services/survey-worker`)

- **Role**: Poll MongoDB `survey_responses` for records lacking agent output or stranded in a stale in-flight state and submit them to the Clinical Writer API.
- **Flow**: `run_forever` schedules `ClinicalWriterJob` → fetch pending documents → POST a normalized `/process` payload to Clinical Writer → update `agentResponse`, `agentResponseStatus`, and `agentResponseUpdatedAt`.
- **Configuration**: tunable via env vars (`MONGO_URI`, `MONGO_DB_NAME`, `CLINICAL_WRITER_URL`, `POLL_INTERVAL_SECONDS`, `BATCH_SIZE`, `PROCESSING_STALE_AFTER_SECONDS`, optional token and timeout).
- **Resilience**: logs failures, marks statuses, and retries stale `processing` records after the configured timeout.

## Clinical Writer Design (`services/clinical-writer-api`)

- **Pipeline**: FastAPI endpoint invokes a LangGraph graph to validate input, route by `input_type`, and generate JSON-only ReportDocument output.
- **Routing**: deterministic by request `input_type` (`consult`, `survey7`, `full_intake`) without LLM-based classification.
- **PromptRegistry**: resolves `prompt_key` to prompt text and version.
  - **Google Drive provider** loads prompt docs from a configured folder or explicit map, exports as `text/plain`, caches with TTL, and uses Drive `modifiedTime` as human-readable `prompt_version`.
- **Prompt config**: `PROMPT_PROVIDER=google_drive|local`, `GOOGLE_DRIVE_FOLDER_ID` or `PROMPT_DOC_MAP_JSON`, and service account credentials via `GOOGLE_APPLICATION_CREDENTIALS`.
- **Configuration**: `AgentConfig` centralizes API keys, model params, and prompt provider configuration; dependencies are injected for testability.
- **Endpoint**: exposed on port `9566` via the root `docker-compose.yml`, path `/process`.

## Flutter Design (`apps/*`)

- **Structure**: feature-first (e.g., `features/<feature>/data|domain|presentation`) with shared utilities under `shared/`.
- **Design system**: `packages/design_system_flutter` provides the `AppTheme.light()` theme seeded with `Colors.orange`, common widgets, input/button styling, and the shared `DsScaffold` page shell.
- **Shared scaffold contract**: full-screen Flutter pages should render through `DsScaffold`, which standardizes `appBar + body + mandatory footer/status bar` while allowing each app to provide its own app bar widgets, route configuration, and workflow-specific content.
- **API consumption**: use generated Dart SDK from `packages/contracts/generated/dart`; manual HTTP clients are discouraged.
- **Apps**:
  - `survey-frontend`: screener dashboard for creating surveys and viewing responses. The screener login page includes registration, login, and forgot-password flows wired to the backend screener endpoints.
  - `survey-patient`: patient-facing flow with configurable screener name/contact build args.
  - `clinical-narrative`: A conversational platform for clinical documentation. It supports session management, voice input with transcription, AI-driven clinical assistance, and document generation.
  - `survey-builder`: An application for administrators and researchers to create and manage surveys. It provides a user-friendly interface for editing all aspects of a survey, including questions and instructions.

## Security and Privacy

- The platform now has a stronger focus on security and privacy, with platform-wide access control, encryption, and audit logging.
- All services and applications are designed to be compliant with LGPD.

## Contracts & Tooling

- **OpenAPI**: `packages/contracts/survey-backend.openapi.yaml` is the single API source of truth.
- **Client generation**: run `tools/scripts/generate_clients.sh` to refresh SDKs under `packages/contracts/generated/`.
- **Backend sanity check**: run `python -m compileall services/survey-backend/app` to validate bytecode compilation before shipping.

## Data & Error Handling

- All services log structured messages for start/stop and failure cases.
- MongoDB object IDs are validated in routes; malformed IDs return 400, missing documents 404, unexpected errors 500.
- Background tasks (email, AI enrichment) are best-effort but do not block the main response after persistence succeeds.
- The canonical response collections are `survey_responses` and `patient_responses`; legacy `survey_results` and `patient_results` are only migration inputs.
- Local screener seed data is created by `tools/migrations/survey-backend/003_populate_new_schema.py`, including:
  - `lapan.hugodepaula@gmail.com` with default password `SystemPassword123!`
  - `maria.vale@holhos.com` with default password `SamplePassword123!`
- `tools/migrations/survey-backend/004_rename_response_collections.py` upgrades older databases to the canonical response collection names without losing data.
- Those default passwords are only valid immediately after migration; any manual reset or use of `/screeners/recover-password` replaces the stored bcrypt hash in MongoDB.
