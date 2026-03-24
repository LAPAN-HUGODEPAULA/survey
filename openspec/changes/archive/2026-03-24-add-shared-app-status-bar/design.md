# Design: Shared Application Status Bar

## Context
The four Flutter applications use the same theme package but do not share a single page-shell abstraction:

- `survey-builder` already uses `DsScaffold` from `design_system_flutter` on at least one primary screen.
- `survey-frontend` uses a `ShellRoute` with `MainLayout`, but several pages still render their own `Scaffold`.
- `survey-patient` and `clinical-narrative` rely on local `AsyncScaffold` helpers plus direct `Scaffold` usage.

Because the app shells are inconsistent, implementing the footer independently in each app would create duplication and drift.

## Decision
Define the status bar as a shared design-system UI primitive and integrate it at the highest practical layout level in each app, while closing all gaps for pages that bypass that shared layout.

This keeps the rendered content, spacing, and styling centralized while allowing each app to adopt it through its current layout structure. Where a single shared shell is already present, the integration should happen there. Where screens still bypass a shared shell, the implementation must update the local scaffold helper or the individual page so that every full-screen route still renders the shared status bar before the change is considered complete.

## Trade-offs
Using a single global shell for all apps would be cleaner long term, but it is broader than the requested change and would force unrelated navigation refactors. The proposal therefore favors:

- a centralized shared widget in `design_system_flutter`
- small app-level integrations in existing scaffolds and layouts, provided they still cover every full-screen page
- no routing or architecture rewrites

## Expected Implementation Shape
- Add a reusable footer/status bar widget to `packages/design_system_flutter/`.
- Extend shared scaffold helpers where available so new and existing screens pick up the footer with minimal per-page edits.
- Enumerate the remaining full-screen pages that do not use those helpers and patch them directly so no route is missed.
- Preserve the exact text across all apps:
  `COPYRIGHT © 2026. Laboratório de Pesquisa Aplicada às Neurociências da Visão - Todos os direitos reservados.`
