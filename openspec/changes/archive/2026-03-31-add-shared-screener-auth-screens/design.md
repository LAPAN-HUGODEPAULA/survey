# Design: Shared Screener Auth Screens

## Context
The repository already has most of the backend pieces for professional authentication: `survey-frontend` logs screeners in through `/screeners/login`, loads the authenticated profile from `/screeners/me`, and stores the active screener session in app state. It also already exposes screener registration and password recovery flows backed by the existing `screeners` collection.

`clinical-narrative` diverges from that model today. Its `clinician_login_page.dart` captures name, registration number, and optional email locally, stores them in an app-local provider, and then grants access to the clinical workflow without authenticating against the platform. That mismatch creates two problems:

- the platform does not actually enforce "registered screener only" across both professional apps
- the auth UI, state model, and account affordances are already drifting between the two apps

The change is cross-cutting because it touches both professional Flutter apps, the shared design-system package, and the platform access-control contract. It also carries an explicit product constraint: no new MongoDB collection may be introduced. The same screener identity, registration, and session model must serve both apps.

From a UI standpoint, the repository already has a usable reference pattern in `survey-frontend`: a centered auth form, platform theme, and a right-side account menu in the app bar. The requested change is to turn that pattern into a reusable professional auth surface that follows current platform visual language rather than inventing a second auth experience.

## Goals / Non-Goals

**Goals:**
- Require a valid screener session before protected workflows can run in both `survey-frontend` and `clinical-narrative`.
- Reuse the existing screener backend endpoints and data model instead of creating a second professional identity store.
- Provide a standard sign-in/sign-up experience across both apps using reusable components from `packages/design_system_flutter`.
- Standardize the right-side account menu pattern so both apps support login/logout/account switching consistently.
- Preserve the public locked access-link flow in `survey-frontend` for patient-facing questionnaire distribution.

**Non-Goals:**
- Introducing MFA, SSO, or a new authentication provider.
- Creating a new clinician-specific backend collection or duplicating screener records.
- Refactoring both apps onto the same router implementation if that is not required for the auth guard behavior.
- Redesigning unrelated professional workflows after login.
- Changing the patient-facing `survey-patient` authentication model.

## Decisions

### 1. Keep a single screener identity and reuse the existing backend auth contract
Both `survey-frontend` and `clinical-narrative` will authenticate against the existing screener endpoints and continue to persist professional users in the current `screeners` collection.

Why this over a new clinician identity model:
- the user explicitly rejected a new MongoDB collection
- the repository already models professional users as screeners
- splitting `clinical-narrative` onto a second identity model would create duplicate registration, duplicate recovery flows, and authorization ambiguity across professional tools

Implementation impact:
- `clinical-narrative` must add the same login/profile/session orchestration that `survey-frontend` already performs
- both apps must treat the authenticated principal as the same screener concept, even if the clinical UI still labels the person as a clinician in some contexts

### 2. Move the canonical auth page body and account-menu composition into `packages/design_system_flutter`
The design system package will become the canonical owner of the professional auth UI building blocks. The shared layer should include:

- a professional auth page shell/body for centered sign-in and sign-up states
- shared form sections and action rows for email/password and screener registration inputs
- standardized loading, validation, and inline feedback presentation
- a reusable right-side account menu widget or composable menu contract

The shared package must remain UI-only. It must not import app routers, repositories, or provider types. Each app keeps orchestration by wiring callbacks and simple data contracts into the shared widgets.

Why this over copying the `survey-frontend` screens into `clinical-narrative`:
- the requested outcome explicitly calls for DRY reuse through `design_system_flutter`
- auth UI drift is already visible and will continue if both apps own separate copies
- the shared package already owns cross-app scaffold and widget primitives, so this is the correct boundary

### 3. Keep app-owned navigation, but enforce app-specific auth gates at bootstrap and protected entry points
The two apps use different navigation structures today:

- `survey-frontend` uses `GoRouter`
- `clinical-narrative` uses `MaterialApp` plus imperative navigation helpers

This change should not force a router migration just to standardize auth. Instead:

- `survey-frontend` should add or tighten route guards around protected professional routes while explicitly exempting `/access/:token`
- `clinical-narrative` should gate its initial entry and protected pages behind authenticated screener session state, then continue using its existing workflow navigation internally

Why this over requiring a full `GoRouter` migration in `clinical-narrative`:
- router unification is not necessary to satisfy the access-control requirement
- keeping app-owned routing reduces migration risk and keeps the change focused on auth and shared UI
- the shared auth widgets can stay router-agnostic if they communicate through callbacks

### 4. Standardize the account menu as a shared pattern with app-specific extensions
The account affordance should stay in the app bar on the right side in both apps, matching the current `survey-frontend` mental model. The shared pattern should guarantee:

- logged-out state exposes entry points for sign-in and sign-up
- logged-in state exposes logout and account-switch actions
- the current app may add its own extra items, but those shared auth actions remain present and recognizable

For `survey-frontend`, this preserves the familiar placement and can continue to include profile/settings entries. For `clinical-narrative`, it introduces the same affordance so the user can log out or change accounts without leaving the app workflow.

Why this over leaving `clinical-narrative` without a persistent account menu:
- the user explicitly requested parity with the right-side `survey-frontend` menu
- account switching and logout are session-management concerns, not one-off login page actions
- a persistent menu reduces dead-end session states in long-lived clinical workflows

### 5. Treat the locked survey link as a public exception rather than an authenticated professional route
The `/access/:token` flow in `survey-frontend` exists to distribute a patient-answerable questionnaire. It must therefore stay reachable without a screener session, even after the main professional app is gated by authentication.

Design consequence:
- route guards must distinguish between professional management routes and patient-distribution routes
- the public access-link route may apply prepared survey context and transition into the patient-answer flow without first forcing screener login

Why this over globally requiring login:
- the user explicitly preserved this distribution workflow
- forcing professional auth on a patient link would break the operational reason the route exists

## Risks / Trade-offs
- [Risk: `clinical-narrative` auth retrofit leaves parts of the workflow unguarded] → Mitigation: define a single authenticated app-entry contract and ensure every protected workflow path flows through it.
- [Risk: shared auth widgets become coupled to `GoRouter` or app providers] → Mitigation: keep the design-system API callback-based and pass plain data models only.
- [Risk: survey-frontend and clinical-narrative still diverge on validation or feedback details] → Mitigation: centralize the repeated auth form layout and validation messaging structure in the shared package.
- [Risk: account-menu standardization conflicts with existing survey-frontend profile/settings behavior] → Mitigation: standardize the required auth actions and allow additive app-specific items rather than collapsing everything to the lowest common denominator.
- [Trade-off: router implementations remain different across the two apps] → Mitigation: accept this for now because it preserves focus and lowers migration cost; revisit router convergence only if future changes need shared route-level behavior.

## Migration Plan
1. Define the shared professional auth widgets and account-menu composition in `packages/design_system_flutter`.
2. Refactor `survey-frontend` auth pages to consume the shared UI while preserving its existing backend calls and `GoRouter` routes.
3. Add authenticated screener session handling to `clinical-narrative` using the existing screener backend endpoints.
4. Replace the local clinician credential form in `clinical-narrative` with the shared sign-in/sign-up flow backed by real auth.
5. Add the right-side account menu to `clinical-narrative` and standardize the shared auth actions across both apps.
6. Add or tighten auth guards so protected professional routes require login, while `/access/:token` remains public in `survey-frontend`.
7. Validate both apps visually and functionally with Flutter analysis and targeted UI verification.

Rollback can be performed per app. Because the shared package owns only UI composition, either app can temporarily revert to its local auth page wrapper while preserving the backend auth contract. If route guarding causes regressions, the public access-link exception can also be restored independently from the rest of the auth UI migration.

## Open Questions
- Should the shared auth surface also absorb password-recovery UI now, or should this change keep password recovery app-owned while standardizing only sign-in/sign-up?
- Should `clinical-narrative` expose a profile/details page after login, or is a menu with account switching and logout sufficient for this change?
