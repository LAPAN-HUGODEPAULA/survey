## ADDED Requirements

### Requirement: Survey-builder MUST expose a dedicated admin login and blocked-access states
The `survey-builder` application MUST present a dedicated login entry for administrative access and MUST provide explicit unauthorized and session-expired states instead of leaving the user in a blank or partially rendered builder screen.

#### Scenario: Admin session expires during builder use
- **WHEN** the builder session expires while the user is using `survey-builder`
- **THEN** the application MUST interrupt further privileged actions
- **AND** it MUST show a session-expired message with a clear path back to the login entry

#### Scenario: Unauthorized screener attempts builder login
- **WHEN** a non-admin screener submits valid professional credentials in the builder login entry
- **THEN** the application MUST keep the user on the login entry with a blocked-access message that explains the account is not authorized for builder administration
- **AND** it MUST prevent navigation into survey, prompt, persona, or access-point management views
