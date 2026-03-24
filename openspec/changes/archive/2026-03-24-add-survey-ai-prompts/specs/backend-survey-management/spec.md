## ADDED Requirements
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
