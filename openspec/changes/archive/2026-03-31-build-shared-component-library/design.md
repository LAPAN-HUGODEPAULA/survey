# Design: Shared Flutter Component Library

## Context
The repository already has the correct package boundary for shared Flutter UI: `packages/design_system_flutter`. All four Flutter apps depend on that package today, and it already owns shared scaffold, footer, button, indicator, chip, dialog, and report widgets.

The remaining duplication is no longer cosmetic:

- `survey-frontend` and `survey-patient` duplicate the same respondent flow screens and support logic.
  - `features/demographics/pages/demographics_page.dart` is highly similar across both apps and repeats the same diagnosis, education, profession, medication, and validation rules.
  - `features/instructions/pages/instructions_page.dart`, `features/survey/pages/survey_page.dart`, and `features/survey/pages/survey_details_page.dart` are identical or nearly identical.
  - `widgets/common/async_scaffold.dart`, demographic data loading, formatting, and validator utilities are duplicated as support code.
- `survey-builder` repeats the same CRUD composition patterns between prompt and persona management.
  - `survey_prompt_list_page.dart` and `persona_skill_list_page.dart` share the same catalog shell, refresh handling, card rows, and confirm-delete flow.
  - `survey_prompt_form_page.dart` and `persona_skill_form_page.dart` share the same save-cancel action row, keyed field patterns, and multiline editor shell, even though persona forms add duplicate-conflict handling.
- `clinical-narrative` is not a full match for the survey apps, but it still duplicates async and patient-entry primitives that can benefit from the same library if the APIs are granular.

Because `design_system_flutter` is already adopted by every app, introducing a second shared package would add dependency and ownership complexity without solving a packaging problem. The change should therefore expand the existing package from "design primitives" into "design primitives plus reusable cross-app components."

## Goals / Non-Goals

**Goals:**
- Remove the highest-value UI and form-rule duplication across the four Flutter apps.
- Keep the shared component library in `packages/design_system_flutter`.
- Define implementation-ready component families for respondent flows and builder CRUD flows.
- Preserve app-owned navigation, repository calls, and provider state by using callbacks and adapter data models.
- Document ownership rules so future reusable widgets are added to the shared package instead of copied into apps.

**Non-Goals:**
- Moving all duplicated app models and services into this change.
- Reworking route structure, screen sequencing, or app-specific business workflows.
- Replacing app-specific repositories or state containers with design-system code.
- Refactoring already-shared widgets such as `ReportView` unless needed to support the new library structure.

## Decisions

### 1. Place the shared component library in `packages/design_system_flutter`
`packages/design_system_flutter` will remain the canonical package and gain a clearer internal structure for reusable feature components, for example:

- `lib/components/async/`
- `lib/components/respondent_flow/`
- `lib/components/admin/`
- `lib/components/forms/`

Public access can continue through `widgets.dart` plus additional focused barrel files if the export surface becomes too large.

Why this over a new package:
- All four apps already import `design_system_flutter`.
- The package already owns cross-app scaffold and report components.
- A second package would split ownership between "theme primitives" and "feature primitives" with little architectural value.

### 2. Extract components as thin reusable sections or shells, not app-owned monolithic routes
The shared library should expose reusable page bodies, sections, and shells that accept callbacks and simple value objects. Each app should keep a thin route wrapper responsible for navigation and state orchestration.

This keeps the package reusable without importing `GoRouter`, app-specific `Provider` classes, or repositories.

Why this over full shared pages:
- `survey-frontend` and `survey-patient` are very close, but their submit and navigation targets diverge.
- `clinical-narrative` only overlaps on subsets of the demographics flow.
- Thin wrappers reduce package coupling and make migration safer.

### 3. First-wave component candidates are fixed up front
The proposal is implementation-ready because the first-wave targets are explicit:

**Respondent-flow candidates**
- `DsAsyncPage` or equivalent wrapper replacing local `AsyncScaffold`
- `PatientIdentitySection` for shared name and patient-identifier fields
- `SurveyDemographicsFormSection` for shared demographic inputs
- `DemographicsCatalogLoader` and shared demographics field helpers for diagnoses, education levels, and professions
- `MedicationUsageField` and diagnosis multi-select composition that preserve the current business rules
- `SurveyInstructionGate` for HTML preamble plus comprehension answer validation
- `SurveyQuestionRunner` for one-question-at-a-time rendering with progress state
- `SurveyDetailsPanel` for reusable survey metadata and rich-text description display

**Survey-builder candidates**
- `AdminCatalogPageShell` for title, refresh, create CTA, loading/error/empty states, and list composition
- `AdminCatalogListItem` or equivalent row builder with edit and delete affordances
- `AdminFormShell` for save-cancel toolbar, scrollable form body, and busy state
- `NormalizedKeyField` for reusable key-format validation
- `InlineConflictMessage` and confirmation-dialog helpers for standardized feedback

### 4. Shared business rules may move with the components when the rules are already duplicated
This change is not only presentational. Where two apps already enforce the same rule set, the corresponding validators and reference-data loaders should move with the shared component contract.

That applies to:
- demographic validators and field rules duplicated between `survey-frontend` and `survey-patient`
- demographic reference-data loading for diagnoses, education levels, and professions
- survey-builder key-format validation used in administrative forms

What remains app-owned:
- repository calls
- selected survey lookup
- app settings persistence
- route transitions after submission or cancellation

### 5. Documentation is a required deliverable, not a follow-up
This migration only stays durable if contributors know where reusable Flutter UI belongs. The implementation should therefore update developer-facing documentation, ideally by:

- adding a focused document under `docs/` describing shared Flutter component ownership, export conventions, and composition rules
- cross-linking that guidance from broader architecture documentation where Flutter package responsibilities are described

## Risks / Trade-offs
- **Risk: `design_system_flutter` becomes a dumping ground** → Mitigation: enforce clear subdirectories and export conventions, and only move code that is reused across apps.
- **Risk: shared components absorb app orchestration concerns** → Mitigation: require callback- and data-model-based APIs; keep routers, providers, and repositories in each app.
- **Risk: package dependency creep** → Mitigation: only add dependencies that are already broadly used by consuming apps and are necessary for the extracted components.
- **Risk: migration changes behavior accidentally** → Mitigation: migrate behind thin wrappers, preserve current route sequences, and verify each app with `flutter analyze` plus representative widget coverage.
- **Trade-off: some duplicate code will remain** → Mitigation: keep this change focused on the highest-value duplicated components and leave broader domain-model consolidation for a later proposal if still needed.

## Migration Plan
1. Create the shared folder and export structure in `packages/design_system_flutter`.
2. Extract async and respondent-flow primitives from `survey-frontend` and `survey-patient`.
3. Migrate those two apps to the shared components first, because they have the largest direct overlap.
4. Extract and migrate the builder CRUD shells for prompt and persona management.
5. Adopt the smaller shared patient-entry and async primitives in `clinical-narrative`.
6. Update documentation and run validation across all affected Flutter packages and apps.

Rollback is straightforward because each migration step can keep the previous app wrapper until the shared component is stable; reverting the wrapper restores the local implementation without changing backend contracts.

## Open Questions
- Should HTML rendering for instructions and survey descriptions move fully into `design_system_flutter`, or should the shared components accept an already-built rich-text widget to keep the package dependency surface smaller?
- Is the team comfortable moving duplicated validators and data loaders into the shared package, or should those stay in a separate follow-up change after the UI extraction proves stable?
