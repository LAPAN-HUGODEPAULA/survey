## ADDED Requirements
### Requirement: Configurable Data Retention Policy
The system MUST support configurable retention rules for sensitive data and apply them consistently across storage locations.

#### Scenario: Apply configured retention rule
- **WHEN** a retention rule is updated by an authorized administrator
- **THEN** the system MUST apply the rule to new and existing records according to the policy

### Requirement: Data Deletion and Anonymization Workflow
The system MUST support authorized deletion and anonymization workflows for personal data with auditability.

#### Scenario: Process a deletion request
- **WHEN** an authorized deletion request is approved
- **THEN** the system MUST delete or anonymize the data and record the action in audit logs

### Requirement: Consent Revocation Handling
The system MUST support consent revocation requests and restrict further processing where consent is the legal basis.

#### Scenario: Patient revokes consent
- **WHEN** a patient revokes consent for a processing activity
- **THEN** the system MUST stop processing under that consent and confirm the change
