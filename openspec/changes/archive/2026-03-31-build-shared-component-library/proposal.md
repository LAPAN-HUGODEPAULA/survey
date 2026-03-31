# Change: Build Shared Component Library

## Why
The Flutter apps already share theme and scaffold primitives, but they still duplicate large chunks of respondent and admin UI. The duplication is now material: `survey-frontend` and `survey-patient` carry near-identical demographics, instructions, survey runner, and survey details screens, while `survey-builder` repeats the same CRUD catalog and form shells for prompts and personas.

This increases maintenance cost, makes business-rule drift more likely, and slows down platform-wide UI changes. The repository already has a shared Flutter package in `packages/design_system_flutter`, so now is the right time to extend it into the canonical home for reusable cross-app components.

## What Changes
- Establish a shared Flutter component library in `packages/design_system_flutter` instead of creating a second package, because all four apps already depend on it and it already hosts shared scaffold and report primitives.
- Extract a first wave of shared respondent-flow components from `survey-frontend` and `survey-patient`, including demographics form sections and rules, instruction comprehension UI, linear survey question presentation, survey details presentation, and async page-state wrappers.
- Extract a first wave of shared admin components from `survey-builder`, including catalog/list shells, save-cancel action bars, key-based form fields, edit-delete row actions, and confirmation-dialog composition.
- Provide shared component APIs that keep routing, repositories, `Provider` state, and app-specific submission flows in each app through callbacks and adapters rather than moving orchestration into the design system.
- Identify a smaller reusable patient-identity form section for `clinical-narrative`, so that app can consume the shared library where overlap exists without forcing the full survey demographics flow onto the clinical workflow.
- Add developer documentation that explains which Flutter UI belongs in `packages/design_system_flutter`, how shared components should be exported, and how apps should compose them without leaking app-specific logic into the package.

## Capabilities

### New Capabilities
- `shared-flutter-component-library`: Define the shared Flutter component library, its ownership rules, the first implementation-ready component families, and the documentation expectations for cross-app reuse.

### Modified Capabilities

## Impact
- Affected code: `packages/design_system_flutter/`, `apps/survey-frontend/`, `apps/survey-patient/`, `apps/survey-builder/`, `apps/clinical-narrative/`
- Likely package updates: `packages/design_system_flutter/pubspec.yaml` and public exports under `packages/design_system_flutter/lib/`
- Candidate migration targets identified during repository review:
  - `survey-frontend` and `survey-patient`: duplicated demographics, instructions, survey runner, survey details, validators, and demographics catalog loading
  - `survey-builder`: repeated prompt/persona catalog screens and editor shells
  - `clinical-narrative`: reusable patient-identity and async-state composition opportunities
- Documentation impact: add or update developer-facing guidance in `docs/` for shared Flutter component ownership and usage
