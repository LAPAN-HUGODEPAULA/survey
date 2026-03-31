## ADDED Requirements

### Requirement: Shared Screener Authentication Across Professional Apps
The existing screener authentication contract MUST serve both `survey-frontend` and `clinical-narrative` without introducing a second professional identity store.

#### Scenario: Existing screener signs into the clinical narrative app
- **WHEN** a registered screener signs into `clinical-narrative` with valid platform credentials
- **THEN** the app MUST authenticate against the existing screener backend contract
- **AND** the authenticated user MUST be resolved from the existing screener identity model rather than a new clinician-specific collection

### Requirement: Shared Screener Registration Entry Across Professional Apps
The existing screener registration contract MUST be reachable from both `survey-frontend` and `clinical-narrative`.

#### Scenario: Register from either professional app
- **WHEN** a user completes screener registration from `survey-frontend` or `clinical-narrative`
- **THEN** the submitted data MUST target the existing screener registration contract
- **AND** the new account MUST be created in the existing `screeners` collection
