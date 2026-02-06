## ADDED Requirements
### Requirement: Access Control
The system SHALL enforce role-based access control for template operations.

#### Scenario: Non-admin edits template
- **WHEN** a non-admin attempts to edit a template
- **THEN** the system denies the action and logs the attempt

### Requirement: Audit Logging
The system SHALL record audit events for template creation, updates, approvals, and archival.

#### Scenario: Record audit event
- **WHEN** a template is approved
- **THEN** the system records the approver, timestamp, and template version
