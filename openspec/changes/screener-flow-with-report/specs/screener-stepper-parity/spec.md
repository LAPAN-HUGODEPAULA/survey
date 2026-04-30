## ADDED Requirements

### Requirement: design_system_flutter MUST provide a shared flow stepper component
`packages/design_system_flutter` SHALL export a `DsFlowStepper` widget that provides a unified visual stepper used by both `survey-frontend` and `survey-patient`. The stepper MUST display stage names, completion states (done, active, todo), and current step highlighting.

#### Scenario: Shared stepper renders in screener flow
- **WHEN** the screener assessment flow is displayed
- **THEN** the `DsFlowStepper` MUST show the screener stages (Dados do paciente, Contexto clínico, Instruções, Questionário, Relatório)
- **AND** the current active step MUST be visually highlighted

#### Scenario: Shared stepper renders in patient flow
- **WHEN** the patient survey flow is displayed
- **THEN** the `DsFlowStepper` MUST show the patient stages (Aviso, Identificação, Boas-vindas, Instruções, Questionário, Relatório)
- **AND** the current active step MUST be visually highlighted

#### Scenario: Stepper reflects step completion state
- **WHEN** a user advances to the next step
- **THEN** the previous step MUST show a "done" visual state
- **AND** the current step MUST show an "active" visual state
- **AND** future steps MUST show a "todo" visual state

### Requirement: survey-frontend MUST use the shared stepper component
The `AssessmentFlowStepper` in `survey-frontend` SHALL be replaced with `DsFlowStepper` configured with the screener stage list.

#### Scenario: Screener flow uses shared stepper
- **WHEN** the screener navigates through the assessment flow
- **THEN** `DsFlowStepper` MUST be displayed at the top of each page
- **AND** the stepper MUST match the visual design of the patient flow stepper

### Requirement: survey-patient MUST use the shared stepper component
The `PatientJourneyStepper` in `survey-patient` SHALL be replaced with `DsFlowStepper` configured with the patient stage list.

#### Scenario: Patient flow uses shared stepper
- **WHEN** the patient navigates through the survey flow
- **THEN** `DsFlowStepper` MUST be displayed at the top of each page
- **AND** the visual design MUST be consistent with the screener flow stepper
