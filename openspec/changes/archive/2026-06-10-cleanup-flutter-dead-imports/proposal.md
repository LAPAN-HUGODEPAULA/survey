## Why

The Flutter applications currently contain a significant number of unused imports (631 according to Skylos reports), which increases cognitive load, complicates maintenance, and clutters the codebase. Cleaning these up ensures a healthier project state and faster analysis times.

## What Changes

- Removal of all unused imports in the `apps/` directory across:
  - `clinical-narrative`
  - `survey-builder`
  - `survey-frontend`
  - `survey-patient`
- Automated verification using `flutter analyze` to ensure no regressions or broken code.
- Manual verification of critical paths (routes, models, repositories) to guarantee behavior consistency.

## Capabilities

### New Capabilities
- `import-maintenance-workflow`: Defines the standard for maintaining clean import sets across the multi-app ecosystem.

### Modified Capabilities
<!-- No existing requirements are changing; this is a non-functional code quality improvement. -->

## Impact

- **Affected Apps**: All four Flutter web applications in `apps/`.
- **Build System**: Clean `flutter analyze` runs across the board.
- **Developer Experience**: Reduced noise in IDEs and faster code reviews.
