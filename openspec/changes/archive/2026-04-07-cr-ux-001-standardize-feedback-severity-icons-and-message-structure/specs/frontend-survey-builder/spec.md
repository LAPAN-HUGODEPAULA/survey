## ADDED Requirements

### Requirement: Survey-builder MUST present administrative feedback in context
The `survey-builder` application MUST present administrative save, validation, conflict, delete, loading, and empty-state feedback through structured in-context feedback surfaces instead of relying only on raw snackbars.

#### Scenario: An administrator encounters a save or validation issue
- **WHEN** the user saves a catalog item or survey form and the operation returns a validation problem or a failed write
- **THEN** the application MUST show the problem in context with a defined severity and readable guidance
- **AND** the message MUST explain whether the user should correct input, retry, or review a conflict

#### Scenario: An administrative action succeeds
- **WHEN** the user completes a create, update, export, or delete action successfully
- **THEN** the application MUST provide a recognizable success state through the canonical feedback model
- **AND** the feedback MAY use a transient container only when the action does not require further interpretation
