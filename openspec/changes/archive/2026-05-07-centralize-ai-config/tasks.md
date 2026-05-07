## 1. Data Model and Backend Preparation

- [x] 1.1 Update `AgentAccessPoint` Pydantic models in `services/survey-backend/app/domain/models/agent_access_point_model.py` to include `systemPromptOverride` and `formatPromptOverride`.
- [x] 1.2 Update the MongoDB repository in `services/survey-backend/app/persistence/repositories/agent_access_point_repo.py` to ensure all fields are persisted.
- [x] 1.3 Update Dart models `AgentAccessPointDraft` and add `AIConfigDraft` in `apps/survey-builder/lib/core/models/agent_access_point_draft.dart`.
- [x] 1.4 Update `AgentAccessPointRepository` in `apps/survey-builder/lib/core/repositories/agent_access_point_repository.dart` for full serialization of new fields.

## 2. Survey Builder UI Implementation

- [x] 2.1 Add "Configuração de IA" expandable section to `apps/survey-builder/lib/features/survey/pages/agent_access_point_form_page.dart` with Provider, Model, and Temperature fields.
- [x] 2.2 Add "Prompts do Orchestrator" expandable section to `agent_access_point_form_page.dart` with text areas for System and Format prompt overrides.
- [x] 2.3 Implement UI state management and form validation for the new configuration blocks in `survey-builder`.

## 3. API Plumb-through and Runtime Resolution

- [x] 3.1 Update `services/survey-backend/app/api/routes/clinical_writer.py` to resolve the selected Access Point and inject overrides into the request to `clinical-writer-api`.
- [x] 3.2 Update `services/clinical-writer-api/clinical_writer_agent/main.py` request model to accept `system_prompt_override` and `format_prompt_override`.
- [x] 3.3 Modify `services/clinical-writer-api/clinical_writer_agent/prompt_registry.py` to prioritize request-level prompt overrides.
- [x] 3.4 Update agent initialization in `services/clinical-writer-api/clinical_writer_agent/agents/` to honor the dynamic model and prompt configuration.

## 4. Verification

- [x] 4.1 Create a test Access Point in `survey-builder` with a recognizable custom system prompt.
- [x] 4.2 Trigger a report generation and confirm via logs that the custom prompt and model parameters were applied.
