# detailed-report-access-point Specification

## Purpose
Backend and builder configuration for detailed clinical reports in the patient survey flow.

## Requirements
### Requirement: System MUST provide a detailed report access point for survey-patient
The backend SHALL seed an access point with key `survey_patient.report.detailed_analysis` that uses the default "Triagem de pacientes" prompt and `patient_condition_report` persona.

#### Scenario: Access point is seeded and available
- **WHEN** the seed script runs
- **THEN** the `agent_access_points` collection MUST contain a document with `accessPointKey: "survey_patient.report.detailed_analysis"`
- **AND** `promptKey` MUST be `"survey7"`
- **AND** `personaSkillKey` MUST be `"patient_condition_report"`
- **AND** `outputProfile` MUST be `"patient_condition_report"`

#### Scenario: Access point is configurable in survey-builder
- **WHEN** an admin opens the access point form in survey-builder
- **THEN** `RuntimeAccessPointCatalog` MUST include `survey_patient.report.detailed_analysis` as a configurable entry
- **AND** the admin MUST be able to select it from the injection point dropdown

### Requirement: survey-builder MUST handle existing access points gracefully
When a user tries to create an access point that already exists (DuplicateKeyError / 409), the survey-builder SHALL detect the existing record and switch to update mode instead of failing.

#### Scenario: User creates an already-seeded access point
- **WHEN** the user selects a configurable injection point that already exists in the database and submits
- **THEN** the survey-builder MUST check if the access point exists before POST
- **AND** if it exists, the survey-builder MUST use PUT to update instead of POST
- **AND** the form MUST NOT show a 409 error to the user
