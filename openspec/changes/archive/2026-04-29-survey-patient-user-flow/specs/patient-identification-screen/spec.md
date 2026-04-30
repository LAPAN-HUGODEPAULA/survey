## ADDED Requirements

### Requirement: System MUST present a mandatory patient identification screen after the initial notice
After the patient accepts the initial notice, the system SHALL navigate to a `PatientIdentificationPage` that collects name, email, and birth date before any other screen.

#### Scenario: Patient completes identification
- **WHEN** the patient fills in name, email, and birth date and taps continue
- **THEN** the system MUST store the patient data in `AppSettings`
- **AND** the system MUST navigate to the welcome page

#### Scenario: Patient tries to skip identification
- **WHEN** the patient taps continue without filling required fields
- **THEN** the system MUST show validation errors for missing required fields
- **AND** the system MUST NOT navigate away from the identification screen

#### Scenario: Patient returns to identification screen on restart
- **WHEN** the user taps "Iniciar nova avaliação" and returns to the entry gate
- **THEN** after accepting the notice again, the identification screen MUST show empty fields (reset state)

### Requirement: Patient identification screen MUST use shared DsPatientIdentitySection
The identification page SHALL use the existing `DsPatientIdentitySection` widget from `packages/design_system_flutter` for name, email, and birth date fields.

#### Scenario: Identification screen renders correctly
- **WHEN** the identification screen is displayed
- **THEN** it MUST render name, email, and birth date fields via `DsPatientIdentitySection`
- **AND** email and birth date fields MUST be shown (`showEmail: true`, `showBirthDate: true`)
