## ADDED Requirements

### Requirement: Survey-builder MUST route privileged writes through auditable backend operations
The `survey-builder` application MUST perform privileged create, update, delete, publish, and authentication actions through backend endpoints that can emit persistent audit records. Local-only state changes MUST NOT be treated as completed administrative actions.

#### Scenario: Admin saves a survey draft
- **WHEN** a builder admin clicks save in the survey editor
- **THEN** the application MUST send the change through the backend write path
- **AND** it MUST not represent the change as completed until the backend acknowledges the auditable operation result

#### Scenario: Admin signs out from builder
- **WHEN** a builder admin performs logout from `survey-builder`
- **THEN** the application MUST use the logout flow defined for the authenticated admin session
- **AND** the operation MUST be representable in the backend audit trail
