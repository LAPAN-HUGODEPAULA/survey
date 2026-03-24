# Change: Refactor Shared Flutter Scaffold

## Why
The LAPAN Flutter applications currently share theme assets, but they do not share a single page-shell abstraction. `survey-builder` already uses `DsScaffold` in part of its flow, while `survey-frontend` uses a lightweight `MainLayout` plus page-owned `Scaffold`s, and both `survey-patient` and `clinical-narrative` duplicate local `AsyncScaffold` wrappers on top of additional direct `Scaffold` usage.

This fragmentation increases UI drift, duplicates layout concerns, and makes platform-wide changes such as shared status bars, common spacing, and page-level accessibility behavior more expensive to implement and verify. A single shared scaffold contract in `packages/design_system_flutter` would reduce duplication while preserving app-specific navigation and app-bar behavior.

## What Changes
- Define a shared Flutter scaffold contract in `packages/design_system_flutter` as the canonical page-shell abstraction for LAPAN applications, standardizing `appBar + body + footer` for full-screen pages.
- Require `survey-frontend`, `survey-patient`, `survey-builder`, and `clinical-narrative` to adopt that shared scaffold for full-screen pages.
- Preserve application-specific navigation and app-bar composition by making the shared scaffold configurable rather than hardcoding route behavior.
- Align the scaffold refactor with the already-approved shared footer requirement so the mandatory footer becomes part of the shared shell contract rather than an optional add-on.
- Sequence the migration as one platform decision with app-specific rollout tasks.
- Establish validation expectations so the migration can confirm all known full-screen routes use the shared scaffold contract.

## Impact
- Affected specs: `shared-flutter-scaffold`
- Related changes: `add-shared-app-status-bar`
- Affected code: `packages/design_system_flutter/`, `apps/survey-frontend/`, `apps/survey-patient/`, `apps/survey-builder/`, `apps/clinical-narrative/`
