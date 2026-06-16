# Security, Access Control & System Boundaries Specification

## Purpose
Consolidates role-based access control, session security, backend authorization policies, administrative access blocks, audit trail records, and outbound API boundaries.

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

### Requirement: Administrative configuration changes MUST be included in the platform audit trail
The platform audit trail MUST include privileged configuration changes originating from `survey-builder`, including prompt, persona, survey, output-profile, and access-point administration as those resources become available.

#### Scenario: Builder persists a configuration write
- **WHEN** a privileged builder API request creates, updates, publishes, or deletes an administrative configuration resource
- **THEN** the platform MUST record a persistent audit event for that write
- **AND** the event MUST be attributable to the authenticated builder admin identity

### Requirement: Builder audit events MUST support operational investigation
Builder audit events MUST capture request correlation identifiers and normalized outcome codes so operators can join audit evidence with backend traces during incident response.

#### Scenario: Support team investigates a failed admin write
- **WHEN** an operator reviews a failed builder configuration change
- **THEN** the audit record MUST include a correlation id or equivalent trace key
- **AND** the outcome metadata MUST distinguish validation failure, authorization denial, and internal error outcomes

### Requirement: Survey-builder MUST require an authenticated admin session
The `survey-builder` application MUST block all privileged administration screens until it has resolved an authenticated screener session and confirmed that the screener is authorized for builder administration.

#### Scenario: Unauthenticated user opens survey-builder
- **WHEN** a user opens `survey-builder` without a valid screener session
- **THEN** the application MUST show the builder login entry instead of rendering administrative content
- **AND** it MUST require successful screener authentication before any survey, prompt, or persona catalog data is requested

#### Scenario: Expired session is restored from storage
- **WHEN** `survey-builder` loads a stored session artifact that is expired, revoked, or rejected by the backend profile check
- **THEN** the application MUST clear the stored session
- **AND** it MUST route the user to the login entry with a session-expired message

### Requirement: Survey-builder MUST only admit screeners promoted as builder administrators
The backend MUST authorize builder sessions only when the authenticated screener record currently has `isBuilderAdmin=true`. Every other screener MUST be denied builder administration access.

#### Scenario: Authorized builder administrator signs in
- **WHEN** a screener with `isBuilderAdmin=true` authenticates successfully
- **THEN** the backend MUST allow the builder session to access privileged builder APIs
- **AND** the frontend MUST route the user into the authenticated admin shell

#### Scenario: Non-admin screener signs in
- **WHEN** a screener who does not have `isBuilderAdmin=true` authenticates successfully
- **THEN** the backend MUST deny builder login with an admin-specific forbidden response
- **AND** the frontend MUST keep the user on the login entry instead of rendering privileged content

### Requirement: Builder authorization MUST be enforced server-side for every privileged route
All builder-managed API routes MUST require the authenticated screener session plus builder-admin authorization. Client-side route guards alone MUST NOT be considered sufficient protection.

#### Scenario: Client bypasses Flutter navigation guard
- **WHEN** a request reaches a builder-managed API route without builder-admin authorization
- **THEN** the backend MUST reject the request even if the client manually constructs the HTTP call
- **AND** the rejection MUST not disclose privileged resource data

### Requirement: Builder administrative actions MUST emit persistent audit events
Every privileged `survey-builder` operation MUST produce a persistent audit event written by the backend. This includes successful and failed create, update, delete, publish, login, logout, and authorization-denied actions.

#### Scenario: Admin updates a questionnaire prompt
- **WHEN** an authorized builder admin updates a questionnaire prompt through the backend API
- **THEN** the system MUST persist an audit event for that action
- **AND** the event MUST record at least the actor identity, action type, target resource identifier, timestamp, correlation id, and outcome

#### Scenario: Unauthorized builder action is denied
- **WHEN** a builder-managed request is rejected because the screener lacks builder-admin authorization
- **THEN** the system MUST persist an audit event for the denied action
- **AND** the event MUST identify the attempted target and the denial outcome without exposing protected resource content

### Requirement: Builder audit records MUST be append-only and queryable by governance keys
The builder audit store MUST preserve audit entries as append-only records and MUST support retrieval by actor, resource type, resource id, action type, timeframe, and correlation id.

#### Scenario: Investigator traces a configuration change
- **WHEN** an authorized operator investigates a prompt or survey configuration incident
- **THEN** the audit records MUST allow filtering by the affected resource id and timeframe
- **AND** the sequence of matching events MUST show who performed each recorded action and whether it succeeded or failed

### Requirement: Mutating Route Authorization
Every survey-backend mutating route SHALL declare an explicit authorization policy or an explicit public-route exception.

#### Scenario: Unauthenticated mutation rejected
- **GIVEN** a protected mutating route
- **WHEN** a request has no valid principal
- **THEN** the route MUST reject the request before business logic executes.

#### Scenario: Public exception documented
- **GIVEN** a mutating route intentionally used for public onboarding or password recovery
- **WHEN** the route is declared
- **THEN** it MUST include an explicit public exception and compensating controls such as rate limiting, token validation, or scoped payload validation.

### Requirement: Route Auth Inventory
The backend SHALL maintain a testable inventory of route authorization requirements.

#### Scenario: Inventory drift
- **GIVEN** a new mutating route is added
- **WHEN** route authorization tests run
- **THEN** the route MUST fail the inventory check unless it has an assigned authorization class.

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

### Requirement: Repository Secret Boundary

The system SHALL NOT store live credentials, API keys, tokens, or patient-service secrets in tracked repository files.

#### Scenario: Tracked runtime env file

- GIVEN a file named .env under services/, WHEN repository secret scanning runs, THEN the scan MUST fail unless the file contains only non-secret placeholders.

#### Scenario: Generated analyzer cache

- GIVEN generated analyzer cache files under .skylos/cache/, WHEN secret scanning runs, THEN findings from those files MAY be suppressed by rule rather than treated as application secrets.

### Requirement: Configuration Startup Validation

The Clinical Writer API SHALL validate required runtime configuration at startup without exposing secret values.

#### Scenario: Missing credential

- GIVEN a required credential is absent, WHEN the service starts, THEN startup MUST fail with a non-secret diagnostic naming the missing setting.

#### Scenario: Diagnostic safety

- GIVEN a credential is present, WHEN logs or health checks are emitted, THEN the credential value MUST NOT be logged or returned.

### Requirement: Safe File Write Boundary

The backend SHALL write generated files only under explicitly configured service-owned directories.

#### Scenario: Traversal rejected

- GIVEN a requested filename containing ../ or an absolute path, WHEN a generated report or transcription artifact is written, THEN the write MUST be rejected.

#### Scenario: Symlink rejected

- GIVEN a target path that resolves through a symlink outside the service-owned directory, WHEN the service attempts to write, THEN the write MUST fail safely.

### Requirement: Outbound Clinical Writer URL Policy

The survey backend SHALL call the Clinical Writer service only through validated configured origins.

#### Scenario: Disallowed target rejected

- GIVEN a configured Clinical Writer URL pointing to link-local metadata, loopback fallback not explicitly enabled, or an unsupported scheme, WHEN health probing runs, THEN no HTTP request MUST be sent.

#### Scenario: Allowed service target

- GIVEN a configured internal Clinical Writer service origin that matches policy, WHEN health probing runs, THEN the request MAY be sent with bounded timeout and safe error handling.

### Requirement: Encryption at Rest
The system MUST encrypt sensitive personal and health data when stored.

#### Scenario: Store patient data
- **WHEN** sensitive patient data is persisted
- **THEN** the stored data MUST be encrypted at rest

### Requirement: Encryption in Transit
The system MUST encrypt all data transmissions between clients and services.

#### Scenario: Submit data to an API
- **WHEN** a client submits data to an API endpoint
- **THEN** the connection MUST use transport encryption

#### Scenario: Reject insecure production traffic
- **GIVEN** the backend runs with `ENVIRONMENT=production`
- **WHEN** a request reaches the service over plain HTTP
- **THEN** the service MUST reject the request
- **AND** it MUST require HTTPS forwarding metadata or a direct HTTPS scheme

### Requirement: Browser transport hardening
Browser-facing services MUST emit defensive response headers and constrain
cross-origin access to explicitly allowed origins.

#### Scenario: Serve a browser response
- **WHEN** the survey backend returns an HTTP response
- **THEN** it MUST emit headers that disable MIME sniffing and framing
- **AND** it MUST apply a strict referrer policy
- **AND** production responses MUST advertise HSTS

#### Scenario: Configure browser origins
- **WHEN** the backend accepts cross-origin browser traffic
- **THEN** it MUST use an explicit allowlist of origins
- **AND** it MUST NOT combine credentialed requests with a wildcard origin

### Requirement: Key Management
The system MUST manage encryption keys separately from stored data and support key rotation procedures.

#### Scenario: Rotate encryption keys
- **WHEN** a key rotation event is initiated
- **THEN** the system MUST rotate keys without exposing plaintext data
