# Software Design Document

## Architecture Overview

- Monorepo organized into `services/`, `apps/`, `packages/`, and `tools/`.
- Backend is FastAPI with repositories for MongoDB access; integrations cover email and a decomposed Clinical Writer client stack.
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
- **Dependency-first authorization**: All route authentication uses centralized `Depends(...)` in `app/api/dependencies/`. `require_screener` validates Bearer JWT tokens and resolves the authenticated `ScreenerModel`; `require_template_admin` chains on it and enforces `isBuilderAdmin=True`. This replaces ad hoc token/header parsing. A route authorization audit test (`test_route_authorization_audit.py`) dynamically inspects `app.routes` and asserts all mutating endpoints are protected or explicitly listed as public exceptions.
- **Domain models**: `app/domain/models/*` define Pydantic schemas for surveys, reusable prompts, patients, and agent responses.
- **Survey schema**: surveys stored in MongoDB embed a compact `prompt` reference while the questionnaire prompt catalog is stored canonically in `QuestionnairePrompts` and remains readable through the `/survey_prompts` API for backward compatibility.
- Each question definition now carries an optional `label` field; migrations fill legacy surveys with descriptive text while the `/surveys` API exposes the label so front-end radars and future agents can show friendly names instead of raw IDs.
- **Persona skill schema**: output persona documents live in the `PersonaSkills` collection and can be managed through `/api/v1/persona_skills`.
- **Persistence**: repositories under `app/persistence/repositories` encapsulate MongoDB CRUD; injected via `app.persistence.deps` to keep handlers decoupled from storage.
- **Integrations**:
  - `app.integrations.clinical_writer.client` is the orchestration layer for AI enrichment submissions.
  - `app.integrations.clinical_writer.resolver` resolves process, status, analysis, and transcription endpoints and applies outbound URL policy checks.
  - `app.integrations.clinical_writer.health` handles `/healthz` diagnostics and `/status/{request_id}` polling.
  - `app.integrations.clinical_writer.normalizer` maps upstream payloads into `AgentResponse`, including retryable quota and timeout handling.
  - `app.integrations.email.service` exposes the shared `FastMail` client used by screener password recovery and manual administrative re-sends. Automatic response emails are disabled to ensure LGPD compliance.
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

- **Architecture**: Independent FastAPI service with a **LangGraph state graph** that separates clinical interpretation from narrative generation. See `docs/multiagent-architecture.md` for the full architectural rationale and `docs/diagrams/langgraph-pipeline.md` for a visual.
- **Orchestration Graph** (6 nodes):
  1. **InputValidator** — Validates request payload structure and flags invalid or inappropriate content.
  2. **DeterministicRouter** — Routes by `input_type` (`consult`, `survey7`, `full_intake`) or short-circuits to error handling.
  3. **ContextLoader** — Retrieves questionnaire interpretation prompts from `QuestionnairePrompts` and persona skills from `PersonaSkills` in MongoDB.
  4. **ClinicalAnalyzer** — Processes response JSON with clinical rules; outputs structured clinical facts (no narrative text).
  5. **PersonaWriter** — Transforms clinical facts into audience-appropriate Markdown narrative following the persona's tone and format.
  6. **OtherInputHandler** — Handles flagged, invalid, or error-causing inputs with a safe fallback response.
  - The **ReflectorNode** (reflection-based safety validation with PASS/FAIL loop) was temporarily bypassed in the `optimize-ai-graph-and-fix-glm` change (May 2026) to reduce token consumption. The architectural intent is preserved in `docs/multiagent-architecture.md`.
- **Multi-Provider Routing**: The service uses a `ModelRouter` with a **primary (GLM) and fallback (Gemini)** policy. It targets Zhipu AI (GLM) via the industry-standard `openai` SDK and falls back to Google Gemini on any error, ensuring high availability and cost optimization. At a higher level, the **AI Agent Catalog** (`AIAgents` MongoDB collection) provides configurable model endpoints managed through Survey Builder, with ordered `agentRefs` routing for automatic primary/fallback resolution.
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
- **Design system**: `packages/design_system_flutter` provides the canonical `AppTheme.dark()` LAPAN theme, including shared dark palette tokens, gradients, tonal surface primitives, common widgets, and the shared `DsScaffold` page shell.
- **Shared professional auth surfaces**: `packages/design_system_flutter` owns the reusable `DsProfessionalSignInCard`, `DsProfessionalSignUpCard`, and `DsAccountMenuButton` primitives used by `survey-frontend` and `clinical-narrative`. Consuming apps provide backend calls, route changes, and session persistence through callbacks.
- **Shared scaffold contract**: full-screen Flutter pages should render through `DsScaffold`, which standardizes the dark page frame, header regions, tonal background, and mandatory footer/status bar while allowing each app to provide its own route configuration and workflow-specific content.
- **Shared surface contract**: repeated route sections should prefer `DsSection`, `DsPanel`, `DsFocusFrame`, and `DsFieldChrome` over local `Card`/`Container` shells, and administrative CRUD routes should prefer `DsAdminCatalogShell` and `DsAdminFormShell`.
- **API consumption**: use generated Dart SDK from `packages/contracts/generated/dart`; manual HTTP clients are discouraged.
- **API consumption**: prefer the generated Dart SDK from `packages/contracts/generated/dart` for stable contract-backed flows. `survey-builder` also uses lightweight `Dio` repositories for prompt and persona admin screens that reuse the same backend routes.
- **Apps**:
  - `survey-frontend`: screener dashboard for creating surveys and viewing responses. Protected professional routes are gated behind screener login, while `/access/:token` remains public for patient-distribution links. The screener auth flow reuses shared sign-in, sign-up, and account-menu components wired to the backend screener endpoints.
  - `survey-patient`: patient-facing flow with configurable screener name/contact build args.
    - The thank-you experience now renders an inline “Avaliação preliminar” card that polls the Clinical Writer response, a legend-rich radar keyed by question labels, and tight actions to add demographics or restart the flow without logging out.
  - `clinical-narrative`: A conversational platform for clinical documentation. It supports session management, voice input with transcription, AI-driven clinical assistance, and document generation. The app now requires an authenticated screener session before protected workflows can start and reuses the same backend screener identity and shared auth UI used by `survey-frontend`.
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
- **Security boundaries**: The shared `packages/python/lapan-core/lapan_core/security_boundaries.py` utility provides path traversal protection (`get_safe_write_path`, symlink rejection) and SSRF protection (`validate_outbound_url`, loopback/link-local blocking in production). Used by all Python services for file writes and outbound URL validation. The same package also exposes `lapan_core.report_formatter.ReportTextFormatter`, which both `survey-backend` and `survey-worker` use to flatten structured Clinical Writer reports without duplicating traversal logic.
- **Configuration management**: All three Python services (`survey-backend`, `survey-worker`, `clinical-writer-api`) use `pydantic-settings` `BaseSettings` for type-safe configuration loaded from environment variables. Services fail-fast at startup in production if required secrets are missing or use insecure development defaults. Secrets are centrallyally rendered from `config/runtime/config.private.json` via `tools/scripts/render_runtime_config.py`.

## Contracts & Tooling

- **OpenAPI**: `packages/contracts/survey-backend.openapi.yaml` is the single API source of truth.
- **Client generation**: run `tools/scripts/generate_clients.sh` to refresh SDKs under `packages/contracts/generated/`.
- **Backend sanity check**: run `python -m compileall services/survey-backend/app` to validate bytecode compilation before shipping.
- **UV Workspace**: Root `pyproject.toml` defines the `uv` workspace with members in `services/survey-backend`, `services/survey-worker`, `services/clinical-writer-api/clinical_writer_agent`, and `packages/python/lapan-core`. A single `uv.lock` at the root locks all dependencies. The shared `lapan-core` package provides cross-service security utilities.

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
