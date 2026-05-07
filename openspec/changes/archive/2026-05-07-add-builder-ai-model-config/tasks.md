## 1. Database & Schema Updates

- [x] 1.1 Create MongoDB migration to add `aiConfig` object to `AgentAccessPoints` collection.
- [x] 1.2 Update Pydantic models in `survey-backend` (contracts/models) to include new `aiConfig` fields.
- [x] 1.3 Update `AgentAccessPointRepository` in `survey-backend` to handle the new `aiConfig` fields.

## 2. Clinical Writer API Refactoring

- [x] 2.1 Update `ProcessRequest` Pydantic model in `clinical-writer-api` to accept `temperature`, `do_sample`, `thinking_mode`, and `enable_caching`.
- [x] 2.2 Update `ContextLoader` node to extract `aiConfig` from request and inject into LangGraph `state`.
- [x] 2.3 Refactor `ClinicalAnalyzer` and `PersonaWriter` nodes to pass parameters from `state` to `ModelRouter.invoke()`.
- [x] 2.4 Update `ModelRouter.invoke()` to support dynamic parameter overrides and apply provider-specific mappings.
- [x] 2.5 Audit and refactor prompt composition logic to ensure Static Instructions are at the start of the final prompt (for Caching).
- [x] 2.6 Enforce MVP "Ultra-Low Cost" defaults in the `ModelRouter` when parameters are absent.

## 3. Survey Builder UI

- [x] 3.1 Update `AgentAccessPointDraft` model in `survey-builder` to include the `aiConfig` object.
- [x] 3.2 Update `AgentAccessPointRepository` in `survey-builder` to serialize/deserialize `aiConfig`.
- [x] 3.3 Create new UI section/tab in Access Point editor for "AI Configuration".
- [x] 3.4 Add form fields for Primary/Fallback providers and models with dropdowns.
- [x] 3.5 Add sliders/inputs for Temperature and Reasoning Effort.
- [x] 3.6 Add toggle for Input Caching.

## 4. Backend & Client Integration

- [x] 4.1 Update `clinical_writer/client.py` in `survey-backend` to pass the `aiConfig` from `AgentAccessPoint` to the AI service.
- [x] 4.2 Update the request loop/polling logic in `survey-backend` (if any) to align with new latency profiles.

## 5. Frontend Improvements

- [x] 5.1 Update polling intervals in `survey_patient` and `survey_frontend` to match the new 15s initial / 10s subsequent logic.
- [x] 5.2 Add high-visibility "Reasoning" waiting state indicators (if applicable based on progress payload).

## 6. Validation & Handover

- [x] 6.1 Add unit tests for `aiConfig` serialization in `survey-backend`.
- [x] 6.2 Add integration tests for `AgentAccessPoint` resolution with AI overrides.
- [x] 6.3 Manually verify cost optimization (caching) via logs when enabled.
## 7. Resilience & Timeout Improvements

- [x] 7.1 Increase backend HTTP timeout to 300s.
- [x] 7.2 Increase frontend polling attempts to 60 (10 minutes total).
- [x] 7.3 Configure multiple uvicorn workers (4) for the agent in VPS.
- [x] 7.4 Standardize on `glm-4-flash` as the default stable model.
- [x] 7.5 Add detailed logging for LLM invocation start/end in the agent.
