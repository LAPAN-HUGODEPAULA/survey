# Design: Shared Flutter Scaffold

## Context
The current Flutter apps already share theme tokens through `packages/design_system_flutter`, but their page-shell abstractions diverge:

- `packages/design_system_flutter/lib/widgets.dart` defines `DsScaffold`, which is currently simple and only used in part of `survey-builder`.
- `packages/design_system_flutter/lib/widgets.dart` now also defines a shared `DsStatusBar`, and the shared footer is already a platform-wide requirement for full-screen pages.
- `survey-frontend` wraps shell-routed content with `MainLayout`, but many route pages still own their own `Scaffold`, so `MainLayout` is not a universal page shell.
- `survey-frontend`, `survey-patient`, and `clinical-narrative` each maintain a local `AsyncScaffold` with effectively the same loading/error wrapper behavior.
- Complex pages such as settings and chat still fit the same broad composition model of `appBar + body`, but they need app-specific app bars and interactions.

This means the duplication problem is real, but the apps are still close enough in structure to converge on one shared scaffold contract.

## Decision
Use a shared scaffold in `packages/design_system_flutter` as the canonical base page shell for all LAPAN Flutter applications.

The refactor should not elevate `survey-frontend`'s `MainLayout` into the platform abstraction because it is app-specific and does not currently own page chrome consistently. It also should not standardize on one of the local `AsyncScaffold` copies because those wrappers are duplicated and too narrow to serve as the canonical shell.

Instead, the design-system scaffold should become the shared contract and expose configuration points for:

- `PreferredSizeWidget? appBar`
- `Widget body`
- shared footer/status bar as part of the canonical full-screen shell
- optional loading and error presentation
- optional layout constraints or safe-area handling needed across apps

App-specific navigation, route transitions, menus, and business logic remain outside the shared scaffold.

## Options Considered
### Option 1: Standardize on `MainLayout`
Pros:
- Minimal change inside `survey-frontend`

Cons:
- Tied to one app
- Not currently universal even within `survey-frontend`
- Poor fit for the other three apps

### Option 2: Standardize on the existing local `AsyncScaffold`
Pros:
- Similar behavior already exists in three apps

Cons:
- Duplicated implementation
- Too narrow for pages that do not need async loading/error wrappers
- Does not address `survey-builder`

### Option 3: Expand `DsScaffold` or introduce a new design-system scaffold
Pros:
- Lives in the correct shared package
- Most compatible with platform-wide reuse
- Supports future shared chrome such as the status bar
- Keeps navigation-specific logic outside the design system

Cons:
- Requires coordinated migration in all four apps
- Needs care to avoid overloading the scaffold API

## Decision Rationale
Option 3 is the most flexible and appropriate because it matches the intended architecture: shared UI primitives belong in the design system, while app-specific route and workflow behavior stays in each application.

This also creates the cleanest foundation for the `add-shared-app-status-bar` change. Without a shared scaffold contract, footer adoption must be patched into multiple wrappers and page-specific scaffolds. With the contract in place, that footer can be composed once and reused everywhere.

Because `add-shared-app-status-bar` has now been implemented, the shared footer is no longer a hypothetical future concern. The scaffold refactor should therefore treat the footer as a mandatory element of the canonical full-screen shell, alongside the app bar and body, rather than as an optional extension point.

## Migration Shape
The migration should proceed in two layers:

1. Introduce the shared scaffold contract in `packages/design_system_flutter`.
2. Migrate each app to consume that contract while preserving local navigation and app bars.

This remains one proposal because the architectural decision is platform-wide, but the execution tasks are split by app to make sequencing, review, and verification manageable.

## Risks
- A shared scaffold can become too generic if it tries to absorb app-specific navigation concerns.
- Some pages may still require direct `Scaffold` ownership during transition if they use unusual layout behavior; those exceptions should be explicit and temporary.
- Cross-app migration increases regression risk unless representative widget coverage is added for each application.
- Documentation can drift if the mandatory footer and shared scaffold responsibilities are not reflected in developer-facing guidance after the refactor.
