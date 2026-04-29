## ADDED Requirements

### Requirement: Shared package MUST provide a multi-select medication autocomplete widget
`packages/design_system_flutter` SHALL export a `DsMedicationAutocompleteField` widget that combines a text input with chip display for selected medications.

#### Scenario: User types to search medications
- **WHEN** the user types 3 or more characters in the autocomplete field
- **THEN** the widget MUST call the medication search API endpoint
- **AND** matching results MUST appear in a dropdown overlay

#### Scenario: User selects a medication from suggestions
- **WHEN** the user taps a suggestion from the dropdown
- **THEN** the medication substance name MUST be added to the selected list
- **AND** an `InputChip` with the medication name and a remove (X) button MUST appear below the text field
- **AND** the text field MUST be cleared for the next search

#### Scenario: User removes a selected medication
- **WHEN** the user taps the X button on a medication chip
- **THEN** the medication MUST be removed from the selected list
- **AND** the chip MUST disappear

#### Scenario: No search results found
- **WHEN** the search returns no results
- **THEN** the dropdown MUST show "Nenhum medicamento encontrado."
- **AND** an "Adicionar manualmente" option MUST appear allowing the user to enter their typed text as an unverified medication

#### Scenario: User adds a manual (unverified) medication
- **WHEN** the user types a medication name, sees no results, and taps "Adicionar manualmente"
- **THEN** the typed text MUST be added to the selected list as a chip
- **AND** the chip MUST be visually distinguishable (e.g., different border style) from verified chips during editing

#### Scenario: Fewer than 3 characters typed
- **WHEN** the user has typed fewer than 3 characters
- **THEN** no API call MUST be made
- **AND** no suggestions MUST be displayed

### Requirement: Autocomplete widget MUST integrate with DsDemographicsFormController
The widget SHALL accept a `List<String>` of selected medications and callbacks for add/remove operations, compatible with the form controller's state management.

#### Scenario: Widget receives initial medications
- **WHEN** the widget is rendered with a pre-populated list of medications
- **THEN** all pre-selected medications MUST appear as chips
