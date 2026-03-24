# Change: Add Shared Application Status Bar

## Why
The LAPAN platform currently does not define a shared footer/status bar across its Flutter applications. Adding one standard status bar ensures the platform presents the same institutional copyright notice in each app and avoids ad hoc per-app variations.

## What Changes
- Add a shared status bar requirement for `survey-frontend`, `survey-patient`, `survey-builder`, and `clinical-narrative`.
- Require the shared status bar on every full-screen page rendered by those applications, including entry, workflow, report, authentication, splash, and unavailable/error pages.
- Define the exact footer text that must be rendered consistently in all four applications.
- Centralize the status bar as a reusable design-system-backed UI element instead of duplicating four separate implementations.

## Impact
- Affected specs: `shared-status-bar`
- Affected code: `packages/design_system_flutter/`, `apps/survey-frontend/`, `apps/survey-patient/`, `apps/survey-builder/`, `apps/clinical-narrative/`
