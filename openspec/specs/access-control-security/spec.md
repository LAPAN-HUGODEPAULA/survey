# access-control-security Specification

## Purpose
Define the platform rules for authentication, authorization, and guarded
connection establishment across APIs and realtime channels.
## Requirements
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

### Requirement: Production AI API authentication
The Clinical Writer API MUST fail closed in production unless an operator
explicitly opts into unauthenticated access for a controlled environment.

#### Scenario: Missing token in production
- **GIVEN** the Clinical Writer runs with `ENVIRONMENT=production`
- **AND** no `API_TOKEN` is configured
- **WHEN** a request reaches a protected endpoint
- **THEN** the service MUST reject the request instead of silently allowing
  anonymous access

### Requirement: Realtime connection admission control
Realtime websocket endpoints MUST validate that the target resource exists and
that the browser origin is allowed before accepting a connection.

#### Scenario: Browser connects from a disallowed origin
- **WHEN** a websocket handshake targets a chat session from an origin outside
  the configured allowlist
- **THEN** the system MUST reject the connection

#### Scenario: Browser connects to an unknown session
- **WHEN** a websocket handshake targets a missing chat session
- **THEN** the system MUST reject the connection
