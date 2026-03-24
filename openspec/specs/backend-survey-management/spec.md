# backend-survey-management Specification

## Purpose
TBD - created by archiving change add-survey-builder-app. Update Purpose after archive.
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

### Requirement: The survey management API MUST persist AI prompt associations on each survey.

Survey payloads MUST allow questionnaires to reference one or more reusable prompts so report-generation applications can discover the available AI outcomes for that questionnaire.

Each survey association MUST expose:

- `promptKey`
- `name`
- `outcomeType`

Each survey MUST contain at most one associated prompt per `outcomeType`.

#### Scenario: Create a survey with associated prompts
- **Given** reusable prompts already exist in the prompt catalog
- **When** a user creates a survey and includes prompt associations in the payload
- **Then** the system MUST persist those associations with the survey
- **And** the created survey response MUST include the stored prompt associations

#### Scenario: Retrieve a survey with associated prompts
- **Given** a survey has associated prompts
- **When** a client requests that survey through the API
- **Then** the response MUST include the associated prompt metadata needed for report selection

#### Scenario: Reject duplicate outcome types on a survey
- **Given** a survey payload includes more than one associated prompt with the same `outcomeType`
- **When** the client submits the create or update request
- **Then** the system MUST reject the request with a validation error

#### Scenario: Reject unknown prompt associations
- **Given** a survey payload references a `promptKey` that does not exist in the prompt catalog
- **When** the client submits the create or update request
- **Then** the system MUST reject the request with a validation error

