## ADDED Requirements

### Requirement: System MUST provide a patient_condition_report persona skill
The backend SHALL seed a persona skill with key `patient_condition_report`, name "Patient Condition Report", output profile `patient_condition_report`, and instructions focused on generating a detailed, structured clinical report.

#### Scenario: Persona is available for access point binding
- **WHEN** a survey-builder admin creates or edits an access point
- **THEN** the persona dropdown MUST include "Patient Condition Report · patient_condition_report"

#### Scenario: Persona outputProfile matches access point binding
- **WHEN** an access point is created with `personaSkillKey: "patient_condition_report"` and `outputProfile: "patient_condition_report"`
- **THEN** the backend MUST accept the binding without validation error

### Requirement: Persona seed MUST include distinct instructions from patient_condition_overview
The `patient_condition_report` persona instructions SHALL focus on comprehensive, structured clinical analysis with clear sections (diagnostic impressions, functional impact, recommendations), distinct from the concise `patient_condition_overview` summary.

#### Scenario: Report persona produces structured output
- **WHEN** the clinical writer processes a survey response using the `patient_condition_report` persona
- **THEN** the output MUST include structured sections suitable for a clinical report
- **AND** the output style MUST differ from the concise `patient_condition_overview` summary
