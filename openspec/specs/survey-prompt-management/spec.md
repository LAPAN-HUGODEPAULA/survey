# survey-prompt-management Specification

## Purpose
This specification defines the catalog of reusable AI prompts used for generating clinical reports from survey responses.
## Requirements
### Requirement: The system MUST provide a MongoDB-backed QuestionnairePrompts catalog for questionnaire-specific clinical logic.

The system MUST store questionnaire clinical instructions in a dedicated `QuestionnairePrompts` collection. These documents MUST represent only the clinical logic that belongs to a questionnaire and MUST remain independent from output-profile style concerns.

#### Scenario: Create a questionnaire prompt
- **Given** an administrator is configuring AI behavior for a questionnaire
- **When** they create a `QuestionnairePrompts` document with a human-readable name, a stable questionnaire prompt key, and questionnaire-specific instructions
- **Then** the system MUST persist that document in MongoDB
- **And** it MUST make that questionnaire prompt available for runtime resolution

#### Scenario: List questionnaire prompts
- **Given** questionnaire prompts exist in the system
- **When** an administrative client requests the questionnaire prompt catalog
- **Then** the system MUST return the stored questionnaire prompt definitions
- **And** it MUST not require persona or output-profile metadata in that catalog response

### Requirement: Questionnaire prompt definitions MUST use stable keys and remain free of persona-specific styling.

Each `QuestionnairePrompts` document MUST have a unique stable key suitable for runtime lookup, a non-empty name, and non-empty clinical instructions. The system MUST reject attempts to encode persona-only concerns inside the questionnaire prompt definition when those concerns belong to `PersonaSkills`.

#### Scenario: Reject a duplicate questionnaire prompt key
- **Given** a questionnaire prompt already exists with a given stable key
- **When** another questionnaire prompt is created or updated to use the same key
- **Then** the system MUST reject the request with a validation error

#### Scenario: Reject an empty questionnaire prompt
- **Given** an administrator submits a questionnaire prompt definition
- **When** the name or clinical instructions are blank
- **Then** the system MUST reject the request with a validation error

### Requirement: The system MUST prevent deleting a prompt that is still associated with a survey.

Deleting a prompt that is still referenced by a questionnaire would create a broken report-generation path and MUST be blocked until the association is removed.

#### Scenario: Attempt to delete a prompt still used by a questionnaire
- **Given** a reusable prompt is associated with at least one survey
- **When** an administrator attempts to delete that prompt
- **Then** the system MUST reject the deletion
- **And** it MUST explain that the prompt is still in use by a questionnaire

