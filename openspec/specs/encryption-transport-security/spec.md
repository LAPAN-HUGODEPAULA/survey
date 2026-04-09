# encryption-transport-security Specification

## Purpose
Define the minimum transport and browser-layer protections required when
LAPAN services expose APIs or web content that handle sensitive clinical and
personal data.
## Requirements
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
