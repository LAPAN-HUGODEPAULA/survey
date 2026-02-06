## ADDED Requirements
### Requirement: LGPD Compliance
The system SHALL apply privacy and consent controls aligned with LGPD.

#### Scenario: Access to sensitive data
- **WHEN** a user requests access to sensitive data
- **THEN** the system verifies authorization and records applicable consent

### Requirement: Audit Trails
The system SHALL record audit trails for relevant operations.

#### Scenario: Record critical operation
- **WHEN** a document is generated or exported
- **THEN** the system records the event with user, date, and action type
