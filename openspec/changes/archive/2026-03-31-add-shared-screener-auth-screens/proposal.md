# Change: Add Shared Screener Auth Screens

## Why
`survey-frontend` already has real screener authentication, but `clinical-narrative` still allows access through a local credentials form that does not authenticate against the platform. At the same time, the professional sign-in and sign-up experience is owned only by `survey-frontend`, which creates UI drift and leaves the two professional apps with inconsistent access control.

The platform now needs a single professional authentication experience because both apps are intended for registered screeners only. This change closes that gap without creating a second professional user store, keeps the locked patient access-link flow public, and uses the shared Flutter design system to avoid duplicating the auth UI in each app.

## What Changes
- Require authentication before a user can access the protected workflows in both `survey-frontend` and `clinical-narrative`.
- Keep the locked screener survey route in `survey-frontend` publicly accessible so clinicians can still distribute questionnaires to patients without requiring patient login.
- Reuse the existing screener backend authentication and registration flow for both apps, including the same `screeners` collection and the same login, registration, and profile endpoints.
- Extract a canonical sign-in/sign-up surface for professional apps into `packages/design_system_flutter`, so both apps consume the same auth page composition and field patterns instead of maintaining parallel screens.
- Standardize the account affordance in the application header, including the right-side menu pattern for login, logout, and account switching, and bring `clinical-narrative` in line with the `survey-frontend` menu behavior.
- Add route-guard expectations, session-handling expectations, and shared-component ownership rules to the affected specs so the behavior is implementation-ready and testable.

## Capabilities

### New Capabilities
- `professional-auth-ui`: Define the shared professional sign-in/sign-up experience, account menu behavior, and app-level authentication entry flow for the screener-facing Flutter applications.

### Modified Capabilities
- `screener-authentication`: Screener credentials and registration must serve both `survey-frontend` and `clinical-narrative` without introducing a new user collection.
- `access-control-security`: Protected professional-app routes must require authentication, while locked patient access links remain accessible without login.
- `shared-flutter-component-library`: Shared professional authentication UI and account-menu composition must live in `packages/design_system_flutter`.
- `screener-profile-management`: The professional account menu behavior must be standardized across the professional apps, including logout and account switching from the header menu.

## Impact
- Affected apps: `apps/survey-frontend/`, `apps/clinical-narrative/`
- Affected shared package: `packages/design_system_flutter/`
- Affected backend/auth integration: `services/survey-backend/` and existing screener endpoints already consumed by `survey-frontend`
- Likely affected routing/state areas:
  - `survey-frontend` route guards and auth entry flow
  - `clinical-narrative` app bootstrap, navigation, and clinician session state
  - shared header/account menu composition
- Constraint: no new MongoDB collection for professional users; the change must continue to use the existing screener identity model and storage
- Validation impact: Flutter analysis and UI verification are required for both professional apps, plus backend contract validation if auth/session API expectations change
