## Context

`clinical_writer_agent` currently builds LLM clients through Gemini-only configuration (`GEMINI_API_KEY`, `PRIMARY_MODEL`, `FALLBACK_MODEL`) and routes retries inside a single-provider path. `survey-backend` already resolves runtime prompt/persona/output-profile through access points and proxies requests to the clinical writer service. `survey-builder` already manages access points and screener settings through backend APIs, and `survey-frontend` depends on unauthenticated `GET /settings/screener` to bootstrap the default questionnaire.

This change introduces provider-level resilience and model configurability with low operational overhead: GLM becomes primary, Gemini becomes fallback, and model choices become admin-managed per access point with startup-seeded defaults from env vars.

## Goals / Non-Goals

**Goals:**
- Support GLM primary and Gemini secondary fallback for all clinical-writer graph stages (analyzer, writer, reflector).
- Resolve provider/model configuration per access point at runtime without redeploy.
- Seed default model values into MongoDB at backend startup using `GEMINI_MODEL` and `GLM_MODEL`.
- Keep current screener questionnaire bootstrap behavior intact for `survey-frontend`.
- Keep admin model editing simple: free-text model strings.

**Non-Goals:**
- Building provider-specific model catalogs or availability checks.
- Changing patient-facing contract for `/clinical_writer/process`.
- Adding dynamic hot-reload in `clinical_writer_agent` independent of backend request payload.
- Replacing existing prompt/persona resolution precedence beyond extending it with model/provider fields.

## Decisions

### 1) Use a standardized LLM factory and runtime router in `clinical_writer_agent`
- Decision: Introduce an internal LLM client abstraction.
  - **GLM Client**: Implementation using the `openai` SDK (AsyncOpenAI) targeting `https://api.z.ai/api/paas/v4/`. It will implement an `.invoke(prompt)` method for graph compatibility.
  - **Gemini Client**: Existing LangChain `ChatGoogleGenerativeAI` integration.
- Rationale: The `openai` SDK is robust, handles complex API behaviors (retries, parsing) natively, and shares underlying dependencies (pydantic, httpx) already present in the project. This is more maintainable than a custom `httpx` wrapper.
- Alternative considered: Raw `httpx` implementation.
  - Rejected in favor of the standardized SDK for better reliability and lower maintenance overhead.

### 2) Fallback on any model error (not only retryable network errors)
- Decision: Router always attempts secondary provider/model when primary invocation raises any exception.
- Rationale: Matches requested behavior and maximizes completion probability.

### 3) Remove Automatic Email Sending in Backend Routes
- Decision: Delete `background_tasks.add_task(send_..._email, ...)` calls from `patient_responses.py` and `survey_responses.py`.
- Rationale: These emails were intended for legacy architecture testing. LGPD compliance requires explicit user consent for data sharing via email, and the current flow sends unsolicited JSON data.
- Note: Keep the `/send_email` re-send endpoint in `survey_responses.py` for manual administrative use if needed, but remove it from the automatic "on-create" hook.

### 4) Resolve model/provider per access point in `survey-backend`
- Decision: Extend access-point resolution to include provider/model settings and pass them to the clinical writer.
- Rationale: Centralizes configuration in the backend which already owns access-point logic.

### 5) Persist defaults in `system_settings` at backend startup
- Decision: Upsert default keys `ai_default_glm_model` and `ai_default_gemini_model` derived from env vars.
- Rationale: Supports auditability and easy updates.

### 5) Keep `GET /settings/screener` public; keep AI writes admin-only
- Decision: Do not move existing screener settings GET to admin auth. Add AI model management only through admin-protected access-point/settings endpoints.
- Rationale: `survey-frontend` calls `GET /settings/screener` during startup without admin session. Locking this endpoint would break default questionnaire loading and access-link user flow.
- Alternative considered: move all screener settings routes to admin auth.
  - Rejected due to immediate regression in unauthenticated screener frontend bootstrap.

### 6) Free-text model fields in builder and backend validation
- Decision: Builder accepts arbitrary non-empty model strings for GLM and Gemini fields, persisted as-is.
- Rationale: Requested behavior and lower operational friction for rare model upgrades.
- Alternative considered: strict enum/dropdown.
  - Rejected because provider model catalogs change and would increase maintenance.

## Risks / Trade-offs

- [Risk] Provider schema differences can produce output-format drift.
  - Mitigation: Keep strict JSON schema parsing and reflection cycle; normalize errors and model version reporting.
- [Risk] Fallback-on-any-error can mask primary provider instability.
  - Mitigation: Emit structured logs/metrics indicating primary failure and fallback usage per request.
- [Risk] New access-point fields may be absent in existing documents.
  - Mitigation: Backward-compatible defaults from `system_settings` and env on read path.
- [Risk] Startup seeding may overwrite intended manual defaults.
  - Mitigation: seed with upsert policy that preserves existing non-empty values unless explicitly configured to refresh.

## Migration Plan

1. Extend domain/repository/API contracts for access-point provider/model fields in backend.
2. Add backend startup seeding for AI default keys in `system_settings`.
3. Extend builder access-point form and repository mapping for new fields.
4. Add runtime forwarding of selected provider/model from backend to clinical writer request payload.
5. Implement provider-aware LLM factory/router in `clinical_writer_agent` and wire analyzer/writer/reflector to it.
6. Add tests across backend resolution, builder mapping, and clinical writer fallback paths.
7. Deploy backend + clinical writer + builder together; rollback by disabling new fields and reverting to Gemini-only config.

## Open Questions

- Should startup seeding update existing defaults when env vars change, or only initialize missing keys?
- Should we expose provider/model used for each stage (analyzer/writer/reflector) separately in response metadata, or keep a single `model_version` string?
