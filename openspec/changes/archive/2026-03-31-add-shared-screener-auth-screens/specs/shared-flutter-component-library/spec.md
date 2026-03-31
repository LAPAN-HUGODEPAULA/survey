## ADDED Requirements

### Requirement: Professional Auth UI MUST Be Shared Through the Flutter Component Library
The canonical professional sign-in, sign-up, and account-menu UI used by `survey-frontend` and `clinical-narrative` MUST live in `packages/design_system_flutter`.

#### Scenario: A professional auth surface is needed in both apps
- **WHEN** `survey-frontend` and `clinical-narrative` need the same professional auth page composition or account-menu affordance
- **THEN** the canonical implementation MUST be owned by `packages/design_system_flutter`
- **AND** the shared component API MUST NOT require app-specific router, provider, or repository classes to be imported into the package
