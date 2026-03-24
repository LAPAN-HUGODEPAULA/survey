## ADDED Requirements
### Requirement: The system MUST provide a reusable survey prompt catalog.

Reusable survey prompts MUST be stored in MongoDB and exposed through application APIs so administrators can create, edit, list, and remove prompt definitions without relying on Google Drive documents.

#### Scenario: Create a reusable survey prompt
- **Given** an administrator is managing prompts for questionnaire reporting
- **When** they create a prompt with a human-readable name, a unique `promptKey`, an `outcomeType`, and prompt text
- **Then** the system MUST persist the prompt in MongoDB
- **And** it MUST return the stored prompt definition through the API

#### Scenario: List reusable survey prompts
- **Given** reusable survey prompts exist in the system
- **When** the builder application requests the prompt catalog
- **Then** the system MUST return the stored prompt definitions with their names, keys, and outcome types

### Requirement: Survey prompt definitions MUST use a stable runtime key and one of the supported outcome types.

The system MUST enforce a stable, code-safe `promptKey` and MUST constrain `outcomeType` to the supported survey reporting taxonomy.

The supported outcome types for survey-based report generation are:

- `patient_condition_overview`
- `clinical_diagnostic_report`
- `clinical_referral_letter`
- `parental_guidance`
- `educational_support_summary`

Each prompt definition MUST have a unique `promptKey` suitable for use in code and runtime requests.

#### Scenario: Reject an unsupported outcome type
- **Given** an administrator submits a prompt definition
- **When** the `outcomeType` is outside the supported set
- **Then** the system MUST reject the request with a validation error

#### Scenario: Reject a duplicate prompt key
- **Given** a prompt already exists with a given `promptKey`
- **When** another prompt is created or updated to use the same `promptKey`
- **Then** the system MUST reject the request with a validation error

### Requirement: The system MUST prevent deleting a prompt that is still associated with a survey.

Deleting a prompt that is still referenced by a questionnaire would create a broken report-generation path and MUST be blocked until the association is removed.

#### Scenario: Attempt to delete a prompt still used by a questionnaire
- **Given** a reusable prompt is associated with at least one survey
- **When** an administrator attempts to delete that prompt
- **Then** the system MUST reject the deletion
- **And** it MUST explain that the prompt is still in use by a questionnaire
