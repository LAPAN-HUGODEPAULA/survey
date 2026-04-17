## ADDED Requirements

### Requirement: Survey-builder MUST provide access-point administration workflows
The `survey-builder` application MUST let authorized administrators list, create, edit, and validate agent access-point definitions alongside existing survey, prompt, and persona catalogs.

#### Scenario: Admin opens the access-point catalog
- **WHEN** an authorized admin selects agent access-point management in `survey-builder`
- **THEN** the application MUST display a dedicated access-point catalog screen
- **AND** it MUST load the existing access-point definitions from the backend

#### Scenario: Admin saves an access point
- **WHEN** the admin submits a valid access-point form with a key, display metadata, prompt selection, persona selection, and output profile
- **THEN** the application MUST persist the definition through the backend API
- **AND** it MUST show the saved configuration in the access-point catalog
