# Tasks: Add Survey Builder Application

This list breaks down the work required to implement the `survey-builder` application. Tasks are ordered to manage dependencies (backend first).

## Phase 1: Backend API Extension

-   [x] **1.1.** Update `packages/contracts/survey-backend.openapi.yaml` to define new CRUD endpoints under a `/surveys` path.
-   [x] **1.2.** Implement a new Pydantic model for the survey in `services/survey-backend/app/models/survey.py` if not already present.
-   [x] **1.3.** Implement the survey repository in `services/survey-backend/app/persistence/repositories/survey_repository.py` to handle database operations.
-   [x] **1.4.** Create a new FastAPI router in `services/survey-backend/app/routers/surveys_router.py` with `GET`, `POST`, `PUT`, `DELETE` operations.
-   [x] **1.5.** Add unit/integration tests for the new `/surveys` endpoints in the `services/survey-backend/tests/` directory.
-   [x] **1.6.** Run `./tools/scripts/generate_clients.sh` to update the Dart client with the new API endpoints.

## Phase 2: Frontend Application Development

-   [x] **2.1.** Create a new Flutter application skeleton under `apps/survey-builder`.
-   [x] **2.2.** Configure the new app to use the shared `packages/design_system_flutter` and the generated Dart API client.
-   [x] **2.3.** Implement the main survey list screen (reading and displaying surveys from `GET /surveys`).
-   [x] **2.4.** Implement the survey creation/editing screen (a form to `POST` or `PUT` to `/surveys`).
-   [x] **2.5.** Implement the survey deletion functionality (`DELETE /surveys/{survey_id}`).
-   [x] **2.6.** Add basic navigation between the list and editor screens.
-   [x] **2.7.** Write widget and integration tests for the new screens.

## Phase 3: Integration and Documentation

-   [x] **3.1.** Add a Dockerfile for the `survey-builder` app and update the main `docker-compose.yml` to include it.
-   [x] **3.2.** Create a `README.md` for the `apps/survey-builder` directory.
-   [ ] **3.3.** Manually test the end-to-end flow: creating, editing, and deleting a survey from the UI (not run in this environment).
