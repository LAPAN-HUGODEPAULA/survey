# backend-survey-management Specification

## Purpose
This specification defines the management plane for surveys and questionnaires, allowing administrators to create, configure, and maintain clinical assessments.
## Requirements
### Requirement: The system MUST provide an API for survey management.

This API MUST expose CRUD (Create, Read, Update, Delete) operations for surveys. It will be consumed by the `survey-builder` frontend application to enable survey administration. All endpoints must be properly authenticated and authorized.

#### Scenario: List all surveys
-   **Given** a user requests the list of surveys
-   **When** they make a `GET` request to `/surveys`
-   **Then** the system SHOULD return a `200 OK` status
-   **And** the response body MUST contain a JSON array of survey objects.

#### Scenario: Create a new survey
-   **Given** a user has valid survey data
-   **When** they make a `POST` request to `/surveys` with the survey data in the body
-   **Then** the system SHOULD return a `201 Created` status
-   **And** the response body MUST contain the newly created survey object, including its system-assigned ID.

#### Scenario: Retrieve a single survey
-   **Given** a valid survey ID exists
-   **When** a user makes a `GET` request to `/surveys/{survey_id}`
-   **Then** the system SHOULD return a `200 OK` status
-   **And** the response body MUST contain the corresponding survey object.

#### Scenario: Update an existing survey
-   **Given** a valid survey ID exists and the user has updated survey data
-   **When** they make a `PUT` request to `/surveys/{survey_id}` with the updated data
-   **Then** the system SHOULD return a `200 OK` status
-   **And** the response body MUST contain the updated survey object.

#### Scenario: Delete a survey
-   **Given** a valid survey ID exists
-   **When** a user makes a `DELETE` request to `/surveys/{survey_id}`
-   **Then** the system SHOULD return a `204 No Content` status.

#### Scenario: Attempt to retrieve a non-existent survey
-   **Given** a survey ID that does not exist
-   **When** a user makes a `GET` request to `/surveys/{invalid_survey_id}`
-   **Then** the system SHOULD return a `404 Not Found` status.

### Requirement: The survey management API MUST persist a single nullable prompt reference on each survey.

Survey payloads MUST allow questionnaires to reference exactly one reusable prompt so report-generation applications can discover the available AI outcome for that questionnaire.

Each prompt reference MUST expose:

- `promptKey`
- `name`

#### Scenario: Create a survey with a prompt reference
- **Given** a reusable prompt already exists in the prompt catalog
- **When** a user creates a survey and includes a prompt reference in the payload
- **Then** the system MUST persist that reference with the survey
- **And** the created survey response MUST include the stored prompt metadata

#### Scenario: Retrieve a survey with a prompt reference
- **Given** a survey has an associated prompt
- **When** a client requests that survey through the API
- **Then** the response MUST include the prompt metadata needed for report generation

#### Scenario: Reject unknown prompt references
- **Given** a survey payload references a `promptKey` that does not exist in the prompt catalog
- **When** the client submits the create or update request
- **Then** the system MUST reject the request with a validation error

### Requirement: The survey management API MUST persist nullable default persona configuration on each survey.

Survey payloads MUST support nullable survey-level default `personaSkillKey` and `outputProfile` values so administrators can configure the default persona behavior for report generation without requiring request-level overrides on every submission.

These fields MUST remain backward compatible for surveys that do not yet define persona configuration.

#### Scenario: Create a survey with default persona configuration
- **Given** a persona skill exists in the persona catalog
- **When** a user creates a survey with `personaSkillKey` and `outputProfile`
- **Then** the system MUST persist those default persona settings with the survey
- **And** the created survey response MUST include the stored values

#### Scenario: Create a survey without persona configuration
- **Given** a user creates a survey without default persona settings
- **When** the survey payload omits `personaSkillKey` and `outputProfile` or sends them as `null`
- **Then** the system MUST accept the request
- **And** the stored survey MUST remain compatible with current fallback behavior

#### Scenario: Reject an unknown survey persona reference
- **Given** a survey payload references a `personaSkillKey` that does not exist in the persona catalog
- **When** the client submits the create or update request
- **Then** the system MUST reject the request with a clear configuration error

