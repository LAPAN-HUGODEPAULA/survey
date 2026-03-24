## ADDED Requirements
### Requirement: Security Audit Trail
The system MUST record security-relevant events including authentication, data access, and data modification.

#### Scenario: Log data access
- **WHEN** a user views a patient consultation
- **THEN** the system MUST record an audit event with user, timestamp, resource, and outcome

### Requirement: Audit Log Protection
The system MUST protect audit logs against modification or deletion and restrict access to authorized personnel.

#### Scenario: Attempt to delete an audit log entry
- **WHEN** a non-authorized user attempts to delete or modify audit logs
- **THEN** the system MUST deny the action and log the attempt

### Requirement: Security Alerts
The system MUST generate alerts for suspicious activity based on configurable thresholds.

#### Scenario: Multiple failed logins
- **WHEN** failed login attempts exceed the configured threshold
- **THEN** the system MUST generate a security alert
