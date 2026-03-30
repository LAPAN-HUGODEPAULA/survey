# Spec: Backend Survey Management

This spec defines the API for managing surveys.

## MODIFIED Requirements

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

Each questionnaire now has at most one reusable AI prompt. The survey contract therefore MUST expose a single nullable `prompt` reference instead of a list of prompt associations.

This is required because the product no longer models multiple prompt outcomes per questionnaire, and the API must match the simpler behavior expected by the builder and downstream report flows.

The `prompt` field may be `null`. When present, it MUST contain:

- `promptKey`
- `name`

The survey API MUST NOT require or return `outcomeType` as part of questionnaire prompt configuration.

#### Scenario: Create a survey with a prompt reference
- **Given** a reusable prompt already exists in the prompt catalog
- **When** a user creates a survey and includes a `prompt` reference in the payload
- **Then** the system MUST persist that single prompt reference with the survey
- **And** the created survey response MUST include the stored `prompt`

#### Scenario: Create a survey without a prompt
- **Given** a user creates a survey before an AI prompt is configured
- **When** they submit the survey payload with `prompt: null`
- **Then** the system MUST accept the request
- **And** the stored survey MUST keep `prompt` as `null`

#### Scenario: Reject an unknown prompt reference
- **Given** a survey payload includes a `prompt.promptKey` that does not exist in the prompt catalog
- **When** the client submits the create or update request
- **Then** the system MUST reject the request with a validation error

#### Scenario: Reject legacy prompt association payloads
- **Given** a client submits `promptAssociations` or `outcomeType` fields for questionnaire prompt configuration
- **When** the request reaches the survey management API
- **Then** the system MUST reject the request as using an unsupported survey prompt shape
