## ADDED Requirements

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
