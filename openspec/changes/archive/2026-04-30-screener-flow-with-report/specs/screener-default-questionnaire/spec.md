## ADDED Requirements

### Requirement: Backend MUST store a default screener questionnaire setting
The system SHALL persist a default questionnaire ID in a `system_settings` MongoDB collection with key `screener_default_questionnaire_id`. This setting determines the questionnaire loaded when a screener starts a new session.

#### Scenario: Default questionnaire is stored
- **WHEN** an admin sets a default questionnaire via survey-builder
- **THEN** the `system_settings` collection MUST contain a document with `key: "screener_default_questionnaire_id"` and `value` set to the questionnaire's MongoDB `_id`

#### Scenario: Default questionnaire is not set
- **WHEN** no default questionnaire has been configured
- **THEN** the system MUST return `null` for the setting
- **AND** the screener MUST be prompted to select a questionnaire manually

### Requirement: Backend MUST provide a screener settings API
The API SHALL expose `GET /v1/settings/screener` and `PUT /v1/settings/screener` for reading and updating screener configuration.

#### Scenario: Read screener settings
- **WHEN** a client calls `GET /v1/settings/screener`
- **THEN** the system MUST return the current screener settings including `default_questionnaire_id` and `default_questionnaire_name`

#### Scenario: Update screener settings
- **WHEN** an admin calls `PUT /v1/settings/screener` with a valid questionnaire ID
- **THEN** the system MUST validate the questionnaire exists
- **AND** the system MUST update the `screener_default_questionnaire_id` setting
- **AND** the system MUST return the updated settings

#### Scenario: Update with invalid questionnaire ID
- **WHEN** an admin calls `PUT /v1/settings/screener` with a questionnaire ID that does not exist
- **THEN** the system MUST return HTTP 422 with a validation error

### Requirement: survey-builder MUST provide a screener settings section
The survey-builder admin interface SHALL include a settings section where admins can configure the default screener questionnaire.

#### Scenario: Admin configures default questionnaire
- **WHEN** an admin navigates to the screener settings section in survey-builder
- **THEN** a dropdown of available questionnaires MUST be displayed
- **AND** the currently configured default questionnaire MUST be pre-selected
- **AND** the admin MUST be able to select a different questionnaire and save

#### Scenario: Admin saves screener settings
- **WHEN** the admin selects a questionnaire and taps save
- **THEN** the system MUST call `PUT /v1/settings/screener`
- **AND** a success feedback message MUST be displayed

### Requirement: survey-frontend MUST load default questionnaire at startup
The screener frontend SHALL load the default questionnaire from the backend when the app initializes and use it as the active questionnaire for new sessions.

#### Scenario: Default questionnaire falls back to CHYPS-V Br Q20
- **WHEN** the screener settings do not yet have an explicit default questionnaire
- **THEN** the system MUST resolve `CHYPS-V Br Q20` as the startup default questionnaire
- **AND** the resolved questionnaire MUST be persisted as `screener_default_questionnaire_id` for subsequent sessions

#### Scenario: App loads with default questionnaire configured
- **WHEN** the screener app starts
- **AND** a default questionnaire is configured in the backend
- **THEN** the app MUST load the default questionnaire
- **AND** the app MUST use it as the active questionnaire without requiring manual selection

#### Scenario: App loads without default questionnaire
- **WHEN** the screener app starts
- **AND** no default questionnaire is configured
- **THEN** the app MUST prompt the screener to select a questionnaire

### Requirement: Active session section MUST display the current questionnaire
The "Sessão profissional ativa" section on the settings or dashboard page SHALL display the name of the currently active questionnaire.

#### Scenario: Screener views active session info
- **WHEN** the screener is on the dashboard or settings page
- **THEN** the "Sessão profissional ativa" section MUST display the name of the active questionnaire
- **AND** the questionnaire name MUST match the default or manually selected questionnaire
