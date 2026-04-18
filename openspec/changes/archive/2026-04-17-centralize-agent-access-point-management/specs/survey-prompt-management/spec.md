## ADDED Requirements

### Requirement: Questionnaire prompts MUST be referenceable from access-point configuration
The questionnaire prompt catalog MUST support stable runtime references from access-point definitions managed in `survey-builder`.

#### Scenario: Prompt appears in access-point configuration
- **WHEN** an administrator configures an agent access point in `survey-builder`
- **THEN** the questionnaire prompt catalog MUST expose prompt entries by stable key and display name
- **AND** the system MUST preserve referential integrity between the access point and the selected prompt

#### Scenario: Admin attempts to delete a prompt bound to an access point
- **WHEN** an administrator tries to delete a questionnaire prompt that is currently referenced by an agent access point
- **THEN** the system MUST reject the deletion
- **AND** it MUST explain that the prompt is still in use by runtime access-point configuration
