# Flutter Shared Components

## Purpose

Define where reusable Flutter UI belongs in the monorepo and how application code should adopt it without moving app-specific workflow logic into the shared package.

## Ownership Rules

- `packages/design_system_flutter` is the canonical home for reusable Flutter UI across `survey-frontend`, `survey-patient`, `survey-builder`, and `clinical-narrative`.
- Shared code may include:
  - page-shell and async-state primitives
  - reusable form sections
  - duplicated validators already used by multiple apps
  - reusable admin CRUD shells
  - reusable respondent-flow presentation components
- Shared code must not import:
  - app-specific routers
  - `Provider` stores from individual apps
  - repository implementations from consuming apps
  - feature-specific orchestration logic

## Current Shared Surface

`design_system_flutter` now contains reusable component families under:

- `lib/components/async/`
- `lib/components/respondent_flow/`
- `lib/components/admin/`
- `lib/components/forms/`
- `lib/widgets/`

The first shared feature wave includes:

- `DsAsyncPage` for loading and error page states
- `DsPatientIdentitySection` for common patient identity fields
- `DsSurveyDemographicsSection` and `DsDemographicsCatalogLoader` for shared demographic forms and reference-data loading
- `DsSurveyInstructionGate` for instruction comprehension gating
- `DsSurveyQuestionRunner` for linear survey execution
- `DsSurveyDetailsPanel` for reusable survey metadata presentation
- `DsAdminCatalogShell` and `DsAdminCatalogItem` for builder catalogs
- `DsAdminFormShell`, `DsNormalizedKeyField`, and `DsInlineConflictMessage` for builder forms

The current professional-auth surface also includes:

- `DsProfessionalSignInCard` for shared screener sign-in, forgot-password entry, loading feedback, and submission messaging
- `DsProfessionalSignUpCard` for shared screener registration, address capture, professional council data, and CEP lookup callbacks
- `DsAccountMenuButton` and `DsAccountMenuItem` for the top-right account menu used by professional apps
- `DsAuthOperationResult` plus the auth form data models that let consuming apps keep backend integration and session state outside the shared package

## Composition Rules

- Keep each application route as a thin wrapper around shared widgets.
- Let the application own:
  - route transitions
  - repository calls
  - provider state
  - side effects such as snack bars, report handoff, or screener locking
  - authentication token persistence and logout/account-switch semantics
- Let the shared package own:
  - field layout
  - repeated validation rules
  - repeated presentation states
  - repeated CRUD shell composition
  - repeated professional auth presentation and account-menu composition

## Implementation Plan For New Reuse

When a repeated Flutter surface appears in more than one app:

1. Extract the repeated UI into `packages/design_system_flutter` behind callbacks or simple data classes.
2. Keep route orchestration in the consuming app.
3. Export the new widget from `packages/design_system_flutter/lib/widgets.dart` only after the API is stable enough for reuse.
4. Add or update widget tests in `packages/design_system_flutter/test/`.
5. Migrate the consuming apps to the shared widget before deleting the local duplicate.
6. Update this document and any broader architecture docs if the shared surface area changes materially.

## Migration Notes

- Prefer extracting sections and shells over moving full pages when applications still diverge in navigation or state management.
- Only move business rules into the shared package when those rules are already duplicated across apps.
- If a component is shared by exactly one app today but is expected to remain app-specific, keep it local.
