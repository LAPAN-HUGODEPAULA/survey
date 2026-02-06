# Design: Survey Builder Application

## 1. Architectural Approach

The user requested that the `survey-builder` application directly access the MongoDB database. However, the established architecture of the LAPAN Survey Platform dictates that frontend applications do not interact directly with the data layer. Instead, they communicate with backend services via a well-defined API contract (OpenAPI).

**Decision:** We will adhere to the existing architectural pattern. The `survey-builder` app will not connect directly to MongoDB. Instead, we will introduce a new set of RESTful endpoints in the `survey-backend` (FastAPI) service.

**Rationale:**

*   **Security:** Direct database access from a client-side application is a significant security vulnerability. It would require embedding database credentials in the application, which can be easily extracted. All access control and validation logic would have to be duplicated in the app, which is not secure.
*   **Separation of Concerns:** The current architecture correctly separates the frontend (presentation) from the backend (business logic and data access). A direct database connection would violate this principle, leading to a more complex and less maintainable system.
*   **Consistency:** All other applications in the ecosystem use the backend API. Introducing a different pattern for this one app would create inconsistency and increase the cognitive load for developers.
*   **Scalability & Maintainability:** A central API allows for better control over database interactions, caching, and future data model changes. If the schema evolves, we only need to update the backend service, not every client application.

## 2. Technical Design

1.  **Backend API (`survey-backend`):**
    *   A new FastAPI router (`/surveys`) will be created.
    *   This router will provide standard CRUD endpoints:
        *   `GET /surveys`: List all surveys (with pagination).
        *   `POST /surveys`: Create a new survey.
        *   `GET /surveys/{survey_id}`: Retrieve a single survey by its ID.
        *   `PUT /surveys/{survey_id}`: Update an existing survey.
        *   `DELETE /surveys/{survey_id}`: Delete a survey.
    *   These endpoints will use the existing repository pattern for database interactions, ensuring business logic and data access are properly handled.
    *   The OpenAPI specification at `packages/contracts/survey-backend.openapi.yaml` will be updated to reflect these new endpoints.

2.  **Frontend Application (`survey-builder`):**
    *   A new Flutter application will be created under `apps/survey-builder`.
    *   It will be configured similarly to the other Flutter apps (`survey-frontend`, `survey-patient`).
    *   It will utilize the shared `packages/design_system_flutter` for a consistent look and feel.
    *   After the backend API is updated, the Dart client will be regenerated using the `./tools/scripts/generate_clients.sh` script.
    *   The app will use the generated Dart client to interact with the new `/surveys` endpoints.

## 3. User Experience Flow

The user will experience a simple, form-based interface:

*   **Main Screen:** A list of existing surveys with options to "Create New" or "Edit/Delete" existing ones.
*   **Editor Screen:** A form that allows creating or editing the survey structure, fields, and properties. The fields will map to the existing MongoDB schema for surveys.

This design ensures the new application is secure, maintainable, and consistent with the rest of the LAPAN Survey Platform.
