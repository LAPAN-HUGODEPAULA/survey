## 1. Backend Configuration & Privacy Cleanup

- [x] 1.1 Extend `AgentAccessPoint` domain models and repository mappings to include provider/model runtime fields.
- [x] 1.2 Update access-point API routes and validation to accept provider/model fields.
- [x] 1.3 Add backend startup seeding for `ai_default_glm_model` and `ai_default_gemini_model` in `system_settings`.
- [x] 1.4 Remove automatic `send_patient_response_email` task in `patient_responses.py`.
- [x] 1.5 Remove automatic `send_survey_response_email` task in `survey_responses.py`.
- [x] 1.6 Update `clinical_writer` route flow to include provider/model precedence resolution.

## 2. Clinical Writer Multi-Provider Routing

- [x] 2.1 Implement `GLMClient` using the `openai` SDK to provide a robust integration.
- [x] 2.2 Implement primary/fallback router with fallback-on-any-error behavior and model-version tracking.
- [x] 2.3 Wire analyzer, writer, and reflector nodes to use provider-aware routing.
- [x] 2.4 Add support for request-level provider/model overrides passed from `survey-backend`.

## 3. Survey-Builder Access-Point UX

- [x] 3.1 Extend survey-builder access-point draft model and repository with provider/model fields.
- [x] 3.2 Add access-point form controls for AI provider/model configuration.
- [x] 3.3 Ensure access-point list/form correctly displays and persists new AI fields.

## 4. Documentation & PR Preparation

- [x] 4.1 Update `docs/api-documentation.md` to remove automatic email references.
- [x] 4.2 Update `docs/software-design.md` with new AI routing and privacy changes.
- [x] 4.3 Add backend tests for access-point resolution and startup seeding.
- [x] 4.4 Add clinical writer tests for GLM-primary success and Gemini fallback.
- [x] 4.5 Stage all changes and commit with a descriptive message to prepare for a Pull Request.
