## 1. Governance Core (Single Schema, Single Authority)

- [x] 1.1 Define canonical AI settings model as `aiConfig` across backend domain models and API contracts.
- [x] 1.2 Remove retired flat AI fields (`aiProvider`, `glmModel`, `geminiModel`) from backend models, selection services, and request wiring.
- [x] 1.3 Add global singleton AI settings repository/service with `aiConfig` shape and strict validation.
- [x] 1.4 Add backend endpoints for global AI settings CRUD restricted to builder admin.
- [x] 1.5 Implement effective configuration resolution chain: Request override > Access Point aiConfig > Global singleton aiConfig > Env fallback.
- [x] 1.6 Remove hardcoded model literals from backend and clinical writer runtime code paths.

## 2. Clinical Writer Executor-Only Refactor

- [x] 2.1 Refactor clinical writer router/bootstrap to consume resolved payload config as execution input.
- [x] 2.2 Remove policy-like model selection behavior from clinical writer internals.
- [x] 2.3 Ensure fallback behavior remains emergency-only and does not reintroduce retired schema patterns.
- [x] 2.4 Add detailed structured logs for model routing decisions, request identifiers, and execution stages.

## 3. Worker Resilience and Diagnostics

- [x] 3.1 Add `WORKER_MAX_RETRIES` env variable in survey-worker settings (default `1` for current debug mode).
- [x] 3.2 Implement bounded retry behavior with terminal `permanently_failed` status.
- [x] 3.3 Persist `retryCount`, `lastError`, and `agentResponseUpdatedAt` consistently on failure.
- [x] 3.4 Add runtime flags to toggle verbose payload/response logging without rebuild.
- [x] 3.5 Log outbound payload, raw clinical writer response, and normalized response when debug flags are enabled.

## 4. Survey Builder Global AI Surface and Inheritance UX

- [x] 4.1 Add global AI settings page in survey-builder using backend global settings endpoints.
- [x] 4.2 Update access point form to expose explicit inheritance choice: Use Global AI Settings vs Override with Access Point aiConfig.
- [x] 4.3 Remove retired flat-field handling from builder repositories and drafts.
- [x] 4.4 Ensure builder writes only canonical `aiConfig` AI settings data.

## 5. Validation

- [x] 5.1 Backend compile check: `uv run python -m compileall services/survey-backend/app`.
- [x] 5.2 Clinical Writer compile/lint check: `pylint --disable=C services/clinical-writer-api/clinical_writer_agent/**/*.py`.
- [x] 5.3 Survey Builder analysis: run `flutter analyze` in `apps/survey-builder`.
- [x] 5.4 Execute targeted tests for access-point resolution, worker retries, and clinical writer routing.
- [x] 5.5 Confirm no runtime usage remains of retired fields (`aiProvider`, `glmModel`, `geminiModel`).

## 6. Documentation Sync (Mandatory)

- [x] 6.1 Update architecture docs to reflect executor-only clinical writer behavior and single-schema `aiConfig` governance.
- [x] 6.2 Update operational/runbook docs to reflect `WORKER_MAX_RETRIES`, permanent failure semantics, and runtime debug logging toggles.
- [x] 6.3 Update builder/admin docs to reflect global AI settings surface and explicit access-point inheritance behavior.
- [x] 6.4 Validate that no documentation still describes retired flat AI fields (`aiProvider`, `glmModel`, `geminiModel`).
