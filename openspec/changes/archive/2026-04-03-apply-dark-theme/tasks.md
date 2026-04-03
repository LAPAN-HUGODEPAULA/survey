## 1. Theme Foundation

- [x] 1.1 Audit all Flutter apps and `packages/design_system_flutter` for current theme entry points, hardcoded colors, duplicated shells, and shared-component gaps
- [x] 1.2 Implement the canonical LAPAN dark theme in `packages/design_system_flutter` based on `docs/lapan-design/lapan-design.md`
- [x] 1.3 Add shared theme tokens/extensions for palette, gradients, surfaces, outlines, spacing, and interaction states
- [x] 1.4 Add the shared Manrope typography configuration and wire it into the canonical theme exports

## 2. Shared Component Expansion

- [x] 2.1 Refactor `DsScaffold` and related shell primitives to provide the canonical dark page frame, header regions, and footer behavior
- [x] 2.2 Add reusable shared surface primitives for tonal panels, section containers, focus frames, and form-field chrome
- [x] 2.3 Add or refactor shared navigation/header primitives so screener, clinician, patient, and builder pages can stay visually aligned without moving route logic into the package
- [x] 2.4 Update existing shared buttons, dialogs, chips, indicators, async states, legal surfaces, respondent-flow widgets, auth widgets, and report widgets to use the new theme contract

## 3. Patient and Professional Survey App Migration

- [x] 3.1 Migrate all `survey-patient` production screens to the shared dark shell and shared visual primitives
- [x] 3.2 Remove remaining local presentation-only wrappers or hardcoded screen styling in `survey-patient`
- [x] 3.3 Migrate all `survey-frontend` production screens to the shared dark shell and shared visual primitives
- [x] 3.4 Remove remaining local presentation-only wrappers or hardcoded screen styling in `survey-frontend`

## 4. Clinical Narrative and Builder Migration

- [x] 4.1 Migrate all `clinical-narrative` production screens to the shared dark shell and shared visual primitives
- [x] 4.2 Refactor specialized chat, narrative, and report surfaces in `clinical-narrative` to shared component variants where appropriate
- [x] 4.3 Migrate all `survey-builder` production screens to the shared dark shell and shared visual primitives
- [x] 4.4 Replace remaining builder-local CRUD or editor presentation patterns with shared administrative primitives where applicable

## 5. Cleanup and Documentation

- [x] 5.1 Remove obsolete light-theme code paths, legacy palette helpers, and unused duplicated wrappers after all apps are migrated
- [x] 5.2 Document the shared dark-theme usage and component ownership rules for future Flutter contributions
- [x] 5.3 Review all changed Flutter screens to confirm that every production route in the four apps uses the shared design system primitives

## 6. Validation

- [x] 6.1 Update or add `design_system_flutter` tests for shared theme and component behavior changed by the rollout
- [x] 6.2 Run `flutter analyze` in `apps/survey-patient`
- [x] 6.3 Run `flutter analyze` in `apps/survey-frontend`
- [x] 6.4 Run `flutter analyze` in `apps/clinical-narrative`
- [x] 6.5 Run `flutter analyze` in `apps/survey-builder`
