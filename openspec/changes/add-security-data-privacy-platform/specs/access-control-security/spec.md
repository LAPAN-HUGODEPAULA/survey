## ADDED Requirements
### Requirement: Role-Based Access Control
The system MUST enforce role-based access rules for screeners, administrators, and patients across APIs and data queries.

#### Scenario: Access denied for unauthorized role
- **WHEN** a user attempts to access a resource outside their role permissions
- **THEN** the system MUST return an authorization error and log the attempt

### Requirement: Resource Ownership Enforcement
The system MUST restrict access to patient records and consultations to authorized owners or assigned care providers.

#### Scenario: Doctor attempts to access another doctor's consultation
- **WHEN** a doctor requests a consultation they do not own or are not assigned to
- **THEN** the system MUST deny access with an authorization error

### Requirement: Session Security
The system MUST manage authenticated sessions with expiration, revocation, and inactivity timeout controls.

#### Scenario: Session expires after inactivity
- **WHEN** a session is inactive beyond the configured timeout
- **THEN** the system MUST invalidate the session and require re-authentication
