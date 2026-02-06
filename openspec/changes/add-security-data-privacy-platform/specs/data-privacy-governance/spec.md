## ADDED Requirements
### Requirement: Legal Basis Documentation
The system MUST document a valid LGPD legal basis for each processing activity involving personal or sensitive health data.

#### Scenario: Record legal basis for a processing activity
- **WHEN** a new processing activity is registered for patient data
- **THEN** the system MUST store the legal basis and purpose alongside the activity

### Requirement: Data Subject Rights Fulfillment
The system MUST support requests for data access, correction, portability, and deletion subject to legal constraints.

#### Scenario: Patient requests data access
- **WHEN** a patient submits a verified access request
- **THEN** the system MUST provide an export of the patient's data within the supported workflow

### Requirement: Privacy by Default and Minimization
The system MUST collect and expose only the minimum data required for the stated purpose and default to the most privacy-protective settings.

#### Scenario: Default data collection
- **WHEN** a patient or screener completes a data entry flow
- **THEN** optional fields MUST be clearly marked and excluded unless explicitly provided

### Requirement: Data Protection Impact Assessment
The system MUST maintain a DPIA record for high-risk processing involving sensitive health data or automated decision support.

#### Scenario: Introduce a high-risk processing change
- **WHEN** a feature introduces automated processing of sensitive health data
- **THEN** the system MUST record a DPIA entry with identified risks and mitigations
