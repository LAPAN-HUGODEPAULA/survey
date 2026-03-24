# Tasks: Refactor Shared Flutter Scaffold

## 1. Shared Scaffold Contract
- [x] 1.1. Define the shared scaffold API and responsibilities in `packages/design_system_flutter/`, with `appBar + body + mandatory shared footer/status bar` as the canonical full-screen shell and support for loading/error states when needed.
- [x] 1.2. Document which layout responsibilities remain app-specific so the shared scaffold does not absorb routing or business logic.

## 2. Survey Frontend Migration
- [x] 2.1. Inventory all full-screen routes in `survey-frontend` that currently use `MainLayout`, local `AsyncScaffold`, or direct `Scaffold`.
- [x] 2.2. Migrate `survey-frontend` full-screen pages to the shared scaffold contract while preserving `GoRouter`, `ShellRoute`, and screener-specific app bars and menus.

## 3. Survey Patient Migration
- [x] 3.1. Inventory all full-screen routes in `survey-patient` that currently use local `AsyncScaffold` or direct `Scaffold`.
- [x] 3.2. Migrate `survey-patient` full-screen pages to the shared scaffold contract while preserving the public screening flow and accessibility expectations.

## 4. Survey Builder Migration
- [x] 4.1. Inventory all full-screen routes in `survey-builder`, including pages already using `DsScaffold` and pages still using direct `Scaffold`.
- [x] 4.2. Migrate `survey-builder` full-screen pages to the shared scaffold contract without regressing existing CRUD workflows.

## 5. Clinical Narrative Migration
- [x] 5.1. Inventory all full-screen routes in `clinical-narrative` that currently use local `AsyncScaffold` or direct `Scaffold`.
- [x] 5.2. Migrate `clinical-narrative` full-screen pages to the shared scaffold contract while preserving chat, narrative, login, report, and thank-you flows.

## 6. Validation
- [x] 6.1. Add or update widget tests to verify representative full-screen routes in each app render through the shared scaffold contract.
- [x] 6.2. Run `flutter analyze` in `apps/survey-frontend`, `apps/survey-patient`, `apps/survey-builder`, and `apps/clinical-narrative`.
- [x] 6.3. Confirm the shared scaffold migration still supports the platform-wide footer/status-bar work tracked in `add-shared-app-status-bar`.
- [x] 6.4. Review and update developer-facing documentation to reflect the shared scaffold components and the mandatory footer/status bar requirement.
