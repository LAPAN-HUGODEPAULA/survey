## MODIFIED Requirements

### Requirement: Clinical Writer MUST resolve questionnaire prompts and persona skills from MongoDB for migrated survey flows.

For survey-derived requests that have been migrated to the new storage model, `clinical-writer-api` MUST resolve two independent prompt components from MongoDB before invoking LangGraph:

- a `QuestionnairePrompts` document for questionnaire-specific clinical logic
- a `PersonaSkills` document for output-profile style and restrictions

The service MUST compose both components into the effective runtime prompt. Hardcoded writer-node prompt text MAY remain only as a temporary fallback for non-migrated flows.

#### Scenario: Compose a school report from MongoDB-backed prompt components
- **Given** a survey-derived request references a questionnaire that has a stored `QuestionnairePrompts` document
- **And** the selected output profile maps to a `PersonaSkills` document for `school_report`
- **When** the request reaches `clinical-writer-api`
- **Then** the service MUST load both MongoDB documents before invoking LangGraph
- **And** it MUST compose questionnaire logic and persona instructions into the effective prompt
- **And** it MUST expose traceable versions for both prompt components

### Requirement: Clinical Writer MUST preserve a controlled fallback path during migration.

MongoDB-backed prompt composition MUST not break request types that have not yet been migrated to the split prompt model.

#### Scenario: A non-migrated prompt flow is requested
- **Given** a request reaches `clinical-writer-api` for a flow that does not yet have both MongoDB prompt components
- **When** prompt resolution runs
- **Then** the service MUST use the documented fallback provider chain or fail with an actionable configuration error
- **And** non-migrated flows such as `clinical-narrative` MUST remain operational during the migration window

## ADDED Requirements

### Requirement: Clinical Writer MUST apply MongoDB prompt edits on the next request without requiring a deploy.

Updates to migrated `QuestionnairePrompts` and `PersonaSkills` documents MUST become effective for subsequent requests without rebuilding containers, redeploying services, or restarting the Clinical Writer process.

#### Scenario: Physician edits the school report persona
- **Given** a physician updates the `PersonaSkills` document used for the school report output profile
- **When** the next school report request is processed
- **Then** the Clinical Writer MUST use the updated persona instructions
- **And** the request MUST complete without requiring a new deploy or a process restart
