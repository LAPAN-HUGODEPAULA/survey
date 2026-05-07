# system-screener Specification

## Purpose
TBD - created by archiving change add-screener-registration. Update Purpose after archive.
## Requirements
### Requirement: Create System Screener
A default "System Screener" user MUST be created in the database.

#### Scenario: System startup
**Given** the `survey-backend` application starts
**When** the database is initialized
**Then** a "System Screener" user with the following data MUST be present in the `screeners` collection:
```json
{
   "cpf": "00000000000",
   "firstName": "LAPAN",
   "surname": "System Screener",
   "email": "lapan.hugodepaula@gmail.com",
   "password": "<randomly_generated_and_hashed>",
   "phone": "31984831284",
   "address": {
     "postalCode": "34000000",
     "street": "Rua da Paisagem",
     "number": "220",
     "complement": "",
     "neighborhood": "Vale do Sereno",
     "city": "Nova Lima",
     "state": "MG"
   },
   "professionalCouncil": {
     "type": "none",
     "registrationNumber": ""
   },
   "jobTitle": "",
   "degree": "",
   "darvCourseYear": null
}
```

### Requirement: Use System Screener in Patient App
The `survey-patient` app MUST use the "System Screener" as the default screener for all survey responses.

#### Scenario: Patient submits a survey
**Given** a patient is using the `survey-patient` app
**When** the patient submits a survey
**Then** the survey response sent to the backend MUST be associated with the "System Screener".

### Requirement: Backend MUST store a default screener questionnaire setting
The system SHALL persist a default questionnaire ID in a `system_settings` MongoDB collection with key `screener_default_questionnaire_id`.

#### Scenario: Default questionnaire is stored
- **WHEN** an admin sets a default questionnaire via survey-builder
- **THEN** the `system_settings` collection MUST contain a document with `key: "screener_default_questionnaire_id"`

### Requirement: survey-frontend MUST load default questionnaire at startup
The screener frontend SHALL load the default questionnaire from the backend when the app initializes and use it as the active questionnaire for new sessions.

#### Scenario: App loads with default questionnaire configured
-   **WHEN** the screener app starts
-   **AND** a default questionnaire is configured in the backend
-   **THEN** the app MUST load the default questionnaire
-   **AND** the app MUST use it as the active questionnaire without requiring manual selection

### Requirement: Backend MUST seed AI default model settings at startup
When the backend starts, it MUST ensure default AI model settings are present in `system_settings` using environment-derived values for Gemini and GLM models.

#### Scenario: Startup with missing model defaults
-   **WHEN** the backend starts and AI default model keys are missing in `system_settings`
-   **THEN** the backend MUST create the missing keys using `GEMINI_MODEL` and `GLM_MODEL` values

#### Scenario: Startup with existing model defaults
-   **WHEN** the backend starts and AI default model keys already exist in `system_settings`
-   **THEN** the backend MUST keep the existing persisted values unless an explicit refresh policy is configured


