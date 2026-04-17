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

### Requirement: Professional App Authentication Gate
The professional applications `survey-frontend` and `clinical-narrative` MUST require an authenticated screener session before granting access to protected professional workflows.

#### Scenario: Unauthenticated user opens a protected professional route
- **WHEN** an unauthenticated user opens a protected route or protected app entry in `survey-frontend` or `clinical-narrative`
- **THEN** the application MUST block access to the protected workflow
- **AND** the application MUST route the user to the professional sign-in entry flow

### Requirement: Locked Patient Access Link Remains Public
The locked screener-distributed access-link flow in `survey-frontend` MUST remain reachable without screener authentication.

#### Scenario: Patient opens a locked survey link while logged out
- **WHEN** a user opens the locked survey route in `survey-frontend` without an authenticated screener session
- **THEN** the application MUST allow the access-link resolution flow to continue without forcing professional login first
- **AND** the route MUST preserve its patient-distribution purpose

### Requirement: Survey-builder administrative surface MUST be fail-closed
The platform MUST treat `survey-builder` as a privileged administrative surface and MUST fail closed whenever authentication or builder-admin authorization cannot be established.

#### Scenario: Builder authorization service is unavailable
- **WHEN** `survey-builder` cannot verify the authenticated screener because the relevant backend authorization check fails or is unavailable
- **THEN** the system MUST deny access to builder administration workflows
- **AND** it MUST present a controlled error state rather than rendering privileged UI optimistically

#### Scenario: Protected builder route is requested without credentials
- **WHEN** a request targets a builder-managed API route without a valid screener token
- **THEN** the system MUST reject the request
- **AND** it MUST not return protected configuration data in the response body

