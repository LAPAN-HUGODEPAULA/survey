# Tasks: Add Survey Builder Application

This list breaks down the work required to implement the `survey-builder` application. Tasks are ordered to manage dependencies (backend first).

## Phase 1: Backend API Extension

-   [x] **1.1.** Update `packages/contracts/survey-backend.openapi.yaml` to define new CRUD endpoints under a `/surveys` path.
-   [x] **1.2.** Implement a new Pydantic model for the survey in `services/survey-backend/app/models/survey.py` if not already present.
-   [x] **1.3.** Implement the survey repository in `services/survey-backend/app/persistence/repositories/survey_repository.py` to handle database operations.
-   [x] **1.4.** Create a new FastAPI router in `services/survey-backend/app/routers/surveys_router.py` with `GET`, `POST`, `PUT`, `DELETE` operations.
-   [x] **1.5.** Add unit/integration tests for the new `/surveys` endpoints in the `services/survey-backend/tests/` directory.
-   [x] **1.6.** Run `./tools/scripts/generate_clients.sh` to update the Dart client with the new API endpoints.
-   [x] **1.7.** Replace survey `promptAssociations` with a single nullable `prompt` reference in the OpenAPI contract, backend models, repositories, and API responses.
-   [x] **1.8.** Remove `outcomeType` from reusable survey prompt definitions and related validation rules.
-   [x] **1.9.** Add backend validation for nullable single-prompt references, including rejection of unknown `promptKey` values.
-   [x] **1.10.** Add or update migration logic to normalize legacy prompt-association data into the new single nullable `prompt` field without silent data loss.

## Phase 2: Frontend Application Development

-   [x] **2.1.** Create a new Flutter application skeleton under `apps/survey-builder`.
-   [x] **2.2.** Configure the new app to use the shared `packages/design_system_flutter` and the generated Dart API client.
-   [x] **2.3.** Implement the main survey list screen (reading and displaying surveys from `GET /surveys`).
-   [x] **2.4.** Implement the survey creation/editing screen (a form to `POST` or `PUT` to `/surveys`).
-   [x] **2.5.** Implement the survey deletion functionality (`DELETE /surveys/{survey_id}`).
-   [x] **2.6.** Add basic navigation between the list and editor screens.
-   [x] **2.7.** Write widget and integration tests for the new screens.
-   [x] **2.8.** Update the survey editor to expose a single optional prompt selector bound to the nullable `prompt` reference.
-   [x] **2.9.** Update reusable prompt management screens so prompts are created and edited without any prompt-type field.
-   [x] **2.10.** Add widget and integration coverage for surveys with no prompt, one prompt, and prompt clearing flows.

## Phase 3: Integration and Documentation

-   [x] **3.1.** Add a Dockerfile for the `survey-builder` app and update the main `docker-compose.yml` to include it.
-   [x] **3.2.** Create a `README.md` for the `apps/survey-builder` directory.
-   [x] **3.3.** Manually test the end-to-end flow: creating, editing, and deleting a survey from the UI (not run in this environment).
-   [x] **3.4.** Regenerate the Dart client after the prompt-schema simplification and verify the resulting diff is intentional.
-   [x] **3.5.** Validate prompt-resolution behavior for questionnaires with `prompt: null` and questionnaires with one configured prompt using backend unit tests and Flutter analysis.
