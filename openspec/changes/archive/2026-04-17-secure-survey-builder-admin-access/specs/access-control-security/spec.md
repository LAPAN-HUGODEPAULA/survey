## ADDED Requirements

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
