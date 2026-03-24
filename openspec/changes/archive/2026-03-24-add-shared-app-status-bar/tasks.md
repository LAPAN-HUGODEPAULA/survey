# Tasks: Add Shared Application Status Bar

## 1. Shared UI Primitive
- [x] 1.1. Add a reusable status bar widget or scaffold integration point in `packages/design_system_flutter/` that renders the shared copyright text.
- [x] 1.2. Ensure the shared status bar supports the current app shells without changing each app's navigation model and can be enforced on every full-screen page.

## 2. Application Integration
- [x] 2.1. Inventory every full-screen route/page in `survey-frontend` and integrate the shared status bar into shell-based routes and standalone screens, including splash, login, registration, profile, settings, access-link, survey, report, and thank-you flows.
- [x] 2.2. Inventory every full-screen route/page in `survey-patient` and integrate the shared status bar into all screens that currently render directly with `Scaffold` or `AsyncScaffold`, including welcome, instructions, survey, demographics, report, and thank-you flows.
- [x] 2.3. Inventory every full-screen route/page in `survey-builder` and integrate the shared status bar into list, form, and any other standalone pages, including `DsScaffold`-based and direct-`Scaffold` screens.
- [x] 2.4. Inventory every full-screen route/page in `clinical-narrative` and integrate the shared status bar into all screens that currently render directly with `Scaffold` or `AsyncScaffold`, including clinician login, demographics, chat, narrative, report, and thank-you flows.

## 3. Validation
- [x] 3.1. Add or update widget tests so each app has verification that representative full-screen routes render the shared status bar, and confirm no known full-screen page is left without coverage.
- [x] 3.2. Run `flutter analyze` in `apps/survey-frontend`, `apps/survey-patient`, `apps/survey-builder`, and `apps/clinical-narrative`.
