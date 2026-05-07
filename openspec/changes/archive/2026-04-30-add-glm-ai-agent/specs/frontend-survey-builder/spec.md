## ADDED Requirements

### Requirement: Survey-builder MUST allow access-point model/provider configuration
The `survey-builder` access-point form MUST allow administrators to define provider/model strings for the clinical writer primary and fallback configuration.

#### Scenario: Admin edits provider/model values in access-point form
- **WHEN** an admin enters provider/model values in the access-point form and saves
- **THEN** the application MUST send those values in create/update access-point API payloads
- **AND** it MUST reload the same values when the access-point form is reopened

### Requirement: Survey-builder MUST accept free-text model names
The access-point model inputs MUST accept any non-empty string value and MUST not restrict values to a static list.

#### Scenario: Admin provides a custom model name
- **WHEN** an admin enters a non-empty custom model string
- **THEN** the application MUST allow submission
- **AND** it MUST persist the provided value without replacing it with a predefined option
