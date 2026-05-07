## MODIFIED Requirements

### Requirement: Shared package MUST provide a multi-select medication autocomplete widget
`packages/design_system_flutter` SHALL export a `DsMedicationAutocompleteField` widget that combines a text input with chip display for selected medications and MUST use in-memory search during typing.

#### Scenario: Widget loads medication catalog once and filters in memory
- **WHEN** the medication field receives focus for the first time
- **THEN** the widget MUST request the complete medication catalog once
- **AND** all subsequent search suggestions during the same session MUST be resolved locally in memory without per-keystroke API calls

#### Scenario: User types to search medications
- **WHEN** the user types in the autocomplete field after the local catalog is loaded
- **THEN** matching results MUST appear from a case-insensitive local filter
- **AND** no additional network request MUST be made for each key typed

#### Scenario: User adds a manual medication and leaves the field
- **WHEN** the user adds a medication that is not present in the catalog
- **THEN** the medication MUST be added to the local in-memory list immediately
- **AND** the UI MUST remain responsive without waiting for server confirmation
- **AND** persistence to the backend MUST be triggered asynchronously when the field loses focus

#### Scenario: Async persistence fails
- **WHEN** async persistence of a new medication fails
- **THEN** the local medication MUST remain available in the current form session
- **AND** the system MUST register a retryable error state for background retry or user feedback
