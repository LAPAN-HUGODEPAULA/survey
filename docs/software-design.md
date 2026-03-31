# Software Design Document

## Architecture Overview

- Monorepo organized into `services/`, `apps/`, `packages/`, and `tools/`.
- Backend is FastAPI with repositories for MongoDB access; integrations cover email and Clinical Writer calls.
- Worker processes augment survey responses asynchronously.
- Clinical Writer API is an external-but-co-located FastAPI + LangGraph service using configurable agents.
- Flutter web apps consume generated SDKs and the shared design system for a consistent experience.

## Backend Design (`services/survey-backend`)

- **Entry point**: `app/main.py` wires CORS, routers, lifecycle logging, and an HTTPS-only guard when `ENVIRONMENT=production`.
- **Browser hardening**: the backend emits `Referrer-Policy`,
  `X-Content-Type-Options`, and `X-Frame-Options` on responses, and adds HSTS
  in production.
- **CORS policy**: browser origins come from `CORS_ALLOWED_ORIGINS` when
  configured; otherwise, local development origins are allowlisted
  explicitly. Wildcard CORS is not used with credentials.
- **Routing**: `/api/v1/survey_prompts`, `/api/v1/persona_skills`, `/api/v1/surveys`, `/api/v1/survey_responses`, `/api/v1/patient_responses` plus `/survey_responses/{id}/send_email` for re-sends.
- **Screener auth**: `/api/v1/screeners/register`, `/api/v1/screeners/login`, `/api/v1/screeners/me`, and `/api/v1/screeners/recover-password` support screener registration, authentication, profile lookup, and password recovery.
- **Domain models**: `app/domain/models/*` define Pydantic schemas for surveys, reusable prompts, patients, and agent responses.
- **Survey schema**: surveys stored in MongoDB embed a compact `prompt` reference while the questionnaire prompt catalog is stored canonically in `QuestionnairePrompts` and remains readable through the `/survey_prompts` API for backward compatibility.
- **Persona skill schema**: output persona documents live in the `PersonaSkills` collection and can be managed through `/api/v1/persona_skills`.
- **Persistence**: repositories under `app/persistence/repositories` encapsulate MongoDB CRUD; injected via `app.persistence.deps` to keep handlers decoupled from storage.
- **Integrations**:
  - `app.integrations.clinical_writer.client` submits responses for AI enrichment.
  - `app.integrations.email.service` dispatches response emails using FastAPI `BackgroundTasks` and exposes the shared `FastMail` client used by screener password recovery.
- **AI traceability minimization**: clinical writer run logs store
  pseudonymized `patient_ref` values instead of raw names or emails when
  correlation is needed.
- **Error handling**: routers translate validation errors into HTTP 400/404, unexpected issues into 500s with structured logs.
- **Sensitive logging posture**: startup and upstream AI failures avoid
  printing generated credentials or full sensitive payload bodies.

## Worker Design (`services/survey-worker`)

- **Role**: Poll MongoDB `survey_responses` for records lacking agent output or stranded in a stale in-flight state and submit them to the Clinical Writer API.
- **Flow**: `run_forever` schedules `ClinicalWriterJob` → fetch pending documents → POST a normalized `/process` payload to Clinical Writer with `prompt_key`, `persona_skill_key`, and `output_profile` → update `agentResponse`, `agentResponseStatus`, and `agentResponseUpdatedAt`.
- **Configuration**: tunable via env vars (`MONGO_URI`, `MONGO_DB_NAME`, `CLINICAL_WRITER_URL`, `POLL_INTERVAL_SECONDS`, `BATCH_SIZE`, `PROCESSING_STALE_AFTER_SECONDS`, optional token and timeout).
- **Resilience**: logs failures, marks statuses, and retries stale `processing` records after the configured timeout.

## Clinical Writer Design (`services/clinical-writer-api`)

- **Architecture**: Independent FastAPI service with a **4-stage LangGraph state graph** that separates clinical interpretation from narrative generation and applies reflection-based safety validation. See `docs/multiagent-architecture.md` for the full architectural rationale.
- **4-Stage Orchestration Graph**:
  1. **ContextLoader** — Retrieves questionnaire interpretation prompts from `QuestionnairePrompts` and persona skills from `PersonaSkills` in MongoDB.
  2. **ClinicalAnalyzer** — Processes response JSON with clinical rules; outputs structured clinical facts (no narrative text).
  3. **PersonaWriter** — Transforms clinical facts into audience-appropriate Markdown narrative following the persona's tone and format.
  4. **ReflectorNode** — Validates grounding, tone, and safety; loops back to PersonaWriter on failure (up to 2 retries).
- **Composable Prompts**: The final prompt is assembled at runtime from three layers: **Domain** (questionnaire-specific clinical rules), **Persona** (tone, vocabulary, output format), and **Contextual Data** (pseudonymized patient response JSON).
- **PromptRegistry**: Composes survey-derived prompts from `QuestionnairePrompts` and `PersonaSkills` in MongoDB and exposes `prompt_version`, `questionnaire_prompt_version`, and `persona_skill_version`.
  - **Questionnaire prompt provider** resolves questionnaire clinical logic from `QuestionnairePrompts` and falls back to legacy `survey_prompts` during migration.
  - **Persona skill provider** resolves tone and restriction documents from `PersonaSkills`.
  - **Fallback providers** keep Google Drive or local prompts available for non-migrated flows such as `clinical-narrative`.
- **Prompt ownership today**:
  - `survey-builder` has UI for questionnaire prompt CRUD, survey-to-prompt association, and persona skill CRUD.
  - Analyzer, writer, and reflector prompt scaffolds remain code-owned in Python.
- **Prompt config**: `PROMPT_PROVIDER=google_drive|local`, `GOOGLE_DRIVE_FOLDER_ID` or `PROMPT_DOC_MAP_JSON`, and service account credentials via `GOOGLE_APPLICATION_CREDENTIALS`. These legacy providers are fallback-only for migrated survey flows.
- **Key Decisions**: Skills stored in MongoDB as a clinical CMS; asymmetric model usage (lightweight for analysis, advanced for critique); API-only inference with no self-hosted GPU infrastructure.
- **Configuration**: `AgentConfig` centralizes API keys, model params, and prompt provider configuration; dependencies are injected for testability.
- **Authentication guard**: `/process`, `/analysis`, and `/transcriptions` use
  bearer auth when `API_TOKEN` is configured. In production, the service
  fails closed unless `API_TOKEN` is set or
  `ALLOW_UNAUTHENTICATED_ACCESS=true` is explicitly provided.
- **Endpoint**: Exposed on port `9566` via the root `docker-compose.yml`, path `/process`.

## Flutter Design (`apps/*`)

- **Structure**: feature-first (e.g., `features/<feature>/data|domain|presentation`) with shared utilities under `shared/`.
- **Design system**: `packages/design_system_flutter` provides the `AppTheme.light()` theme seeded with `Colors.orange`, common widgets, input/button styling, and the shared `DsScaffold` page shell.
- **Shared scaffold contract**: full-screen Flutter pages should render through `DsScaffold`, which standardizes `appBar + body + mandatory footer/status bar` while allowing each app to provide its own app bar widgets, route configuration, and workflow-specific content.
- **API consumption**: use generated Dart SDK from `packages/contracts/generated/dart`; manual HTTP clients are discouraged.
- **API consumption**: prefer the generated Dart SDK from `packages/contracts/generated/dart` for stable contract-backed flows. `survey-builder` also uses lightweight `Dio` repositories for prompt and persona admin screens that reuse the same backend routes.
- **Apps**:
  - `survey-frontend`: screener dashboard for creating surveys and viewing responses. The screener login page includes registration, login, and forgot-password flows wired to the backend screener endpoints.
  - `survey-patient`: patient-facing flow with configurable screener name/contact build args.
  - `clinical-narrative`: A conversational platform for clinical documentation. It supports session management, voice input with transcription, AI-driven clinical assistance, and document generation.
    - HTML preview windows open with `noopener noreferrer`, and blob URLs are
      revoked after use.
  - `survey-builder`: An application for administrators and researchers to create and manage surveys. It provides a user-friendly interface for editing all aspects of a survey, including questions and instructions.
    - It also supports reusable questionnaire prompt CRUD, persona skill CRUD, and lets a survey reference one optional prompt.
    - It does not provide survey-level persona assignment or output-profile selection; persona management remains a separate global catalog.
    - The web rich-text editor sanitizes restored/pasted HTML and restricts
      links to approved schemes (`http`, `https`, `mailto`, `tel`).

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
