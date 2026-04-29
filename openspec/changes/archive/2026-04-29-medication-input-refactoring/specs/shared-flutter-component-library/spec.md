## MODIFIED Requirements

### Requirement: Survey respondent applications MUST reuse shared respondent-flow components
The applications `survey-frontend` and `survey-patient` SHALL consume shared respondent-flow components for the duplicated survey experience, including async page state, demographic data capture, instruction comprehension, linear question presentation, and survey metadata presentation.

#### Scenario: A survey app renders a duplicated respondent-flow screen
- **WHEN** `survey-frontend` or `survey-patient` renders a demographics, instructions, survey runner, or survey details screen
- **THEN** the screen MUST be composed from shared components exported by `packages/design_system_flutter`
- **AND** the application MAY keep a thin local page wrapper for navigation, repository access, and provider integration

#### Scenario: Medication input uses shared autocomplete component
- **WHEN** the demographics form shows the medication section and the user has selected "Sim"
- **THEN** the form MUST render `DsMedicationAutocompleteField` instead of a plain `TextFormField`
- **AND** selected medications MUST be tracked as a `List<String>` in the form controller

### Requirement: DsDemographicsFormController MUST manage medication as a list
The form controller SHALL track selected medications as `List<String>` instead of a single `TextEditingController`. The `DsDemographicsSubmission.medication` field SHALL be `List<String>`.

#### Scenario: Form controller medication state
- **WHEN** the form controller is initialized
- **THEN** `selectedMedications` MUST be an empty `List<String>`
- **AND** the controller MUST expose `addMedication(String)` and `removeMedication(String)` methods

#### Scenario: Form submission with medications
- **WHEN** the form is submitted with `usesMedication == 'Sim'`
- **THEN** `DsDemographicsSubmission.medication` MUST contain the list of selected medication names
- **AND** validation MUST fail if the list is empty

#### Scenario: Form submission without medications
- **WHEN** the form is submitted with `usesMedication == 'Não'`
- **THEN** `DsDemographicsSubmission.medication` MUST be an empty list

#### Scenario: Validation item for empty medication list
- **WHEN** `usesMedication == 'Sim'` and `selectedMedications` is empty
- **THEN** the validation summary MUST include an item for "Nome do(s) medicamento(s)" indicating the field is required
