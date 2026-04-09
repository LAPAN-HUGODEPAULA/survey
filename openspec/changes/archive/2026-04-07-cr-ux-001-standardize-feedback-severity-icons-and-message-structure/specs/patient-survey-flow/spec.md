## ADDED Requirements

### Requirement: Patient survey flow MUST use structured feedback messaging
The `survey-patient` flow MUST present important informational, success, warning, and error states through structured feedback containers that match the user's context in the journey.

#### Scenario: A patient triggers a demographics validation problem
- **WHEN** the patient attempts to continue with missing required information in the demographics flow
- **THEN** the application MUST present the validation state near the affected inputs or section
- **AND** the patient MUST receive clear guidance on what needs attention without relying only on a transient snackbar

#### Scenario: The patient sees survey-processing or report-state feedback
- **WHEN** the thank-you or report flow needs to communicate submission, fallback, warning, or report-preparation state
- **THEN** the application MUST render those updates through structured status surfaces with explicit severity and readable text
- **AND** the flow MUST distinguish informational progress from warnings and errors
