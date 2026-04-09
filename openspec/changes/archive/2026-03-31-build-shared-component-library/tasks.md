# Tasks: Build Shared Component Library

## 1. Shared Package Contract

- [x] 1.1 Create the shared component folder and export structure in `packages/design_system_flutter` for async-state, respondent-flow, admin CRUD, and form-section components.
- [x] 1.2 Define public callback and data-model contracts for shared components without importing app-specific routers, repositories, or provider classes.
- [x] 1.3 Add any strictly necessary package dependencies to `packages/design_system_flutter` and keep the public API surface minimal and documented.

## 2. Respondent Flow Extraction

- [x] 2.1 Extract a shared async page-state wrapper to replace the duplicated local `AsyncScaffold` implementations.
- [x] 2.2 Extract shared demographics form sections, validators, and reference-data loading used by `survey-frontend` and `survey-patient`.
- [x] 2.3 Extract a shared instruction comprehension component for HTML preamble rendering and answer gating.
- [x] 2.4 Extract a shared linear survey runner component and a shared survey details presentation component.
- [x] 2.5 Extract a smaller shared patient-identity form section that `clinical-narrative` can compose without adopting the full survey demographics workflow.

## 3. Survey-Builder CRUD Extraction

- [x] 3.1 Extract a shared admin catalog shell for title, refresh, create action, loading, error, empty, and list composition states.
- [x] 3.2 Extract shared catalog row actions and confirmation-dialog helpers for edit and delete flows.
- [x] 3.3 Extract a shared admin form shell with save-cancel actions, busy state, and reusable keyed-field validation helpers.

## 4. App Migrations

- [x] 4.1 Migrate `apps/survey-frontend` to the new shared respondent components while preserving screener navigation and locked-assessment behavior.
- [x] 4.2 Migrate `apps/survey-patient` to the same shared respondent components while preserving report handoff and thank-you flow behavior.
- [x] 4.3 Migrate `apps/survey-builder` prompt and persona catalog or form screens to the shared admin components, then refactor additional survey-form sub-sections where the shared primitives fit.
- [x] 4.4 Migrate `apps/clinical-narrative` to the shared async and patient-identity components where applicable without changing chat, narrative, or report orchestration.

## 5. Validation And Documentation

- [x] 5.1 Add or update widget tests for representative shared components and their thin app wrappers.
- [x] 5.2 Run `flutter analyze` in `packages/design_system_flutter`, `apps/survey-frontend`, `apps/survey-patient`, `apps/survey-builder`, and `apps/clinical-narrative`.
- [x] 5.3 Update developer-facing documentation in `docs/` to define shared Flutter component ownership, export conventions, and composition rules for future work.
