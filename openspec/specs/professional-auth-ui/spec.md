# professional-auth-ui Specification

## Purpose
Define the shared professional authentication surfaces that must be reused across the protected Flutter apps.
## Requirements
### Requirement: Shared Professional Sign-In Surface
The platform MUST provide a shared professional sign-in surface in `packages/design_system_flutter` for the authenticated screener entry flow used by `survey-frontend` and `clinical-narrative`.

#### Scenario: Render the sign-in entry in either professional app
- **WHEN** an unauthenticated user opens the professional auth entry flow in `survey-frontend` or `clinical-narrative`
- **THEN** the app MUST render the canonical shared sign-in UI from `packages/design_system_flutter`
- **AND** the consuming app MUST keep ownership of navigation, repository calls, and session state wiring through callbacks or adapter contracts

### Requirement: Shared Professional Sign-Up Surface
The platform MUST provide a shared professional sign-up surface in `packages/design_system_flutter` for screener registration in `survey-frontend` and `clinical-narrative`.

#### Scenario: Render the registration entry in either professional app
- **WHEN** a user chooses to create a new professional account from `survey-frontend` or `clinical-narrative`
- **THEN** the app MUST render the canonical shared sign-up UI from `packages/design_system_flutter`
- **AND** the registration surface MUST collect the screener identity fields required by the existing screener registration contract

### Requirement: Shared Professional Auth Feedback States
The shared professional auth experience MUST present loading, validation, and submission feedback consistently across the professional apps.

#### Scenario: Submit an auth form from a professional app
- **WHEN** the user submits the shared sign-in or sign-up form
- **THEN** the consuming app MUST be able to drive a standard loading state, validation feedback, and submission error or success messaging through the shared UI contract
