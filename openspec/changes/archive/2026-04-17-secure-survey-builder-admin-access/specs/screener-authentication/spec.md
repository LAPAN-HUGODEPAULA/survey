## ADDED Requirements

### Requirement: Screener authentication contract MUST support survey-builder admin bootstrap
The existing screener authentication contract MUST support `survey-builder` as a professional client that can sign in, resolve the authenticated screener profile, and determine whether the session may proceed into admin-only workflows.

#### Scenario: Builder resolves authenticated screener profile
- **WHEN** `survey-builder` completes screener login or restores a stored token
- **THEN** the existing screener authentication stack MUST allow the app to retrieve the authenticated screener profile
- **AND** the returned profile MUST be usable by the builder authorization layer to decide whether the screener is the allowed admin

#### Scenario: Builder reuses professional session semantics
- **WHEN** a valid screener session already exists from a supported professional flow
- **THEN** `survey-builder` MUST be able to reuse that session contract
- **AND** it MUST not require a second builder-specific credential or identity record
