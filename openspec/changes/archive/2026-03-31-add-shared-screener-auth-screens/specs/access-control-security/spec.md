## ADDED Requirements

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
