## Why

The Flutter apps currently share only a basic light Material theme, while the new LAPAN visual standard in `docs/lapan-design/lapan-design.md` requires a platform-wide dark interface, a canonical amber palette, Manrope typography, tonal layering, and stricter component rules. The current implementation still mixes app-local app bars, hardcoded oranges, raw `Card` surfaces, and duplicated wrappers, so the design cannot be applied consistently to every screen without first centralizing the visual system in `packages/design_system_flutter`.

## What Changes

- Create a canonical shared dark theme in `packages/design_system_flutter` based on the "Clinical Nocturne" guidance from `docs/lapan-design/lapan-design.md`.
- Promote the color palette, typography, spacing, surface hierarchy, and interaction states into reusable theme tokens and shared theme extensions.
- Expand the shared Flutter component library with reusable shell, app-bar, card/panel, form-field, section, feedback-state, and data-presentation primitives needed across all apps.
- Standardize common navigation and page-shell composition so each Flutter app keeps its own routing and workflows but renders through the same visual primitives.
- Migrate `survey-patient`, `survey-frontend`, `clinical-narrative`, and `survey-builder` so every production screen adopts the new shared design standards.
- Add validation expectations for design-system adoption, including removal of legacy hardcoded light-theme styling and direct page-local duplication where a shared primitive exists.

## Capabilities

### New Capabilities
- `shared-dark-theme`: Define the canonical LAPAN dark visual language, including shared color tokens, typography, tonal surfaces, component states, and rules for platform-wide Flutter usage.

### Modified Capabilities
- `shared-flutter-component-library`: Extend the shared package requirements so reusable visual primitives, common layout sections, and cross-app shells live in `packages/design_system_flutter` and are adopted before app-local implementations.
- `shared-flutter-scaffold`: Update the shared scaffold requirements so every Flutter app screen renders through a canonical dark shell structure with consistent header, body, and footer behavior.

## Impact

- Affected code: `packages/design_system_flutter/`, `apps/survey-patient/`, `apps/survey-frontend/`, `apps/clinical-narrative/`, `apps/survey-builder/`.
- Affected documentation/specs: `docs/lapan-design/lapan-design.md`, `openspec/specs/shared-flutter-component-library/spec.md`, `openspec/specs/shared-flutter-scaffold/spec.md`, and the new `openspec/specs/shared-dark-theme/spec.md`.
- Validation impact: `flutter analyze` will be required in each affected Flutter app, and shared component/theme exports in `packages/design_system_flutter` will need test coverage updates where shared behavior changes.
