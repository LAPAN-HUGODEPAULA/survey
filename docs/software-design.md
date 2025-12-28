# Software Design Document

## Architecture Overview
- Monorepo organized into `services/`, `apps/`, `packages/`, and `tools/`.
- Backend is FastAPI with repositories for MongoDB access; integrations cover email and Clinical Writer calls.
- Worker processes augment survey responses asynchronously.
- Clinical Writer API is an external-but-co-located FastAPI + LangGraph service using configurable agents.
- Flutter web apps consume generated SDKs and the shared design system for a consistent experience.

## Backend Design (`services/survey-backend`)
- **Entry point**: `app/main.py` wires CORS, routers, and lifecycle logging.
- **Routing**: `/api/v1/surveys`, `/api/v1/survey_responses`, `/api/v1/patient_responses` plus `/survey_responses/{id}/send_email` for re-sends.
- **Domain models**: `app/domain/models/*` define Pydantic schemas for surveys, patients, and agent responses.
- **Persistence**: repositories under `app/persistence/repositories` encapsulate MongoDB CRUD; injected via `app.persistence.deps` to keep handlers decoupled from storage.
- **Integrations**: 
  - `app.integrations.clinical_writer.client` submits responses for AI enrichment.
  - `app.integrations.email.service` dispatches response emails using FastAPI `BackgroundTasks`.
- **Error handling**: routers translate validation errors into HTTP 400/404, unexpected issues into 500s with structured logs.

## Worker Design (`services/survey-worker`)
- **Role**: Poll MongoDB for survey responses lacking `agentResponse` data and submit them to the Clinical Writer API.
- **Flow**: `run_forever` schedules `ClinicalWriterJob` → fetch pending documents → POST to Clinical Writer → update `agentResponse`, `agentResponseStatus`, and timestamps.
- **Configuration**: tunable via env vars (`MONGO_URI`, `MONGO_DB_NAME`, `CLINICAL_WRITER_URL`, `POLL_INTERVAL_SECONDS`, `BATCH_SIZE`, optional token and timeout).
- **Resilience**: logs failures and marks statuses so retry logic can reprocess items.

## Clinical Writer Design (`services/clinical-writer-api`)
- **Pipeline**: FastAPI endpoint invokes a LangGraph graph to validate, classify, and generate medical narratives with an LLM backend.
- **Classification Strategy Pattern** (imported from prior docs):
  - `ClassificationContext` executes prioritized strategies: inappropriate-content detection → JSON payload detection → conversation detection → fallback “other”.
  - Strategies are registered via `AgentConfig` factories and can be extended without changing the calling code.
  - The selected classification routes the request to the appropriate agent (e.g., JSON processor vs. conversation processor) before invoking the LLM.
- **Configuration**: `AgentConfig` centralizes API keys, model params, and strategy registration; dependencies are injected for testability.
- **Endpoint**: exposed on port `9566` when run via `services/clinical-writer-api/docker-compose.yml`.

## Flutter Design (`apps/*`)
- **Structure**: feature-first (e.g., `features/<feature>/data|domain|presentation`) with shared utilities under `shared/`.
- **Design system**: `packages/design_system_flutter` provides the `AppTheme.light()` theme seeded with `Colors.orange`, common widgets, and input/button styling.
- **API consumption**: use generated Dart SDK from `packages/contracts/generated/dart`; manual HTTP clients are discouraged.
- **Apps**:
  - `survey-frontend`: screener dashboard for creating surveys and viewing responses.
  - `survey-patient`: patient-facing flow with configurable screener name/contact build args.
  - `clinical-narrative`: renders AI-generated narratives.

## Contracts & Tooling
- **OpenAPI**: `packages/contracts/survey-backend.openapi.yaml` is the single API source of truth.
- **Client generation**: run `tools/scripts/generate_clients.sh` to refresh SDKs under `packages/contracts/generated/`.
- **Backend sanity check**: run `python -m compileall services/survey-backend/app` to validate bytecode compilation before shipping.

## Data & Error Handling
- All services log structured messages for start/stop and failure cases.
- MongoDB object IDs are validated in routes; malformed IDs return 400, missing documents 404, unexpected errors 500.
- Background tasks (email, AI enrichment) are best-effort but do not block the main response after persistence succeeds.
