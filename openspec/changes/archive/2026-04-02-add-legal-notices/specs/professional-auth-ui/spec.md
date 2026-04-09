## ADDED Requirements

### Requirement: Shared Professional Initial Notice Gate
The platform MUST provide a shared professional initial-notice acknowledgement surface in `packages/design_system_flutter` for the post-login entry flow used by `survey-frontend` and `clinical-narrative`.

#### Scenario: Screener without a recorded agreement logs in
- **WHEN** an authenticated screener enters `survey-frontend` or `clinical-narrative` and their profile has no `initialNoticeAcceptedAt` value
- **THEN** the app MUST render the canonical shared initial-notice acknowledgement UI from `packages/design_system_flutter`
- **AND** the consuming app MUST keep ownership of navigation, repository calls, and session state wiring through callbacks or adapter contracts

#### Scenario: Screener with a recorded agreement logs in
- **WHEN** an authenticated screener enters `survey-frontend` or `clinical-narrative` and their profile already has an `initialNoticeAcceptedAt` value
- **THEN** the app MUST bypass the initial-notice gate
- **AND** it MUST allow the screener to proceed directly to the protected professional workflow
