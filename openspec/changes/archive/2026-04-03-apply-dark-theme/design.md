## Context

The repository has four Flutter applications: `survey-patient`, `survey-frontend`, `clinical-narrative`, and `survey-builder`. All four already depend on `packages/design_system_flutter`, but the shared package currently exposes only a light `AppTheme.light()` seeded from `Colors.orange`, a minimal `ColorPalette.greenToRed`, and a limited set of reusable widgets. In practice, multiple screens still define their own page chrome and surface styling with direct `AppBar`, `Card`, `Container`, `Border.all`, and `Colors.orange` usage, which prevents the platform from applying `docs/lapan-design/lapan-design.md` consistently.

The target visual language is cross-cutting and affects theme tokens, typography, shells, forms, cards, dialogs, reports, chat surfaces, admin CRUD screens, respondent flows, and navigation wrappers. Because the design standard must reach every Flutter screen, the migration needs a staged approach that first stabilizes the shared package, then replaces app-local duplication.

## Goals / Non-Goals

**Goals:**
- Establish `packages/design_system_flutter` as the single source of truth for the LAPAN dark visual language.
- Encode the amber-on-charcoal palette, Manrope typography, tonal layering, focus treatment, and component state rules from `docs/lapan-design/lapan-design.md` into reusable theme tokens and shared widgets.
- Provide canonical shared primitives for shells, headers, panels, input surfaces, action groups, list rows, empty/error/loading states, and report/chat/admin surfaces.
- Migrate all full-screen Flutter routes to those shared primitives while preserving each app's routing, repositories, and feature workflow ownership.
- Create an implementation order that reduces visual regressions and avoids parallel theme logic across apps.

**Non-Goals:**
- Redesign business workflows, route maps, or backend contracts.
- Introduce per-app visual themes or runtime theme switching.
- Rebuild every screen from scratch when a shared primitive migration can preserve structure.
- Change localization rules; all user-facing Flutter UI remains pt-BR.

## Decisions

### Decision: Create a canonical dark theme contract in `design_system_flutter`
The shared package will own the canonical `ThemeData` and any required `ThemeExtension` or token classes for colors, typography, gradients, radii, spacing, elevation, and interaction states.

Rationale:
- The current `AppTheme.light()` cannot express the "Clinical Nocturne" system and leaves apps to compensate locally.
- A central contract prevents drift such as `Colors.orange`, legacy light surfaces, or app-specific interpretations of shared states.

Alternatives considered:
- Keep a base Material theme and patch screen styles locally: rejected because it would preserve divergence and make future changes expensive.
- Maintain separate app themes that reference common constants: rejected because the user explicitly requested a stable unified design across every app and screen.

### Decision: Add shared surface primitives before migrating app screens
The implementation will add reusable widgets for common visual structures, including a shared dark page shell, navigation/header wrappers, tonal panels, focus-frame containers, section blocks, field chrome, and standardized feedback states.

Rationale:
- The repo already has duplicated wrappers (`AsyncScaffold`, local navigation app bars) and many direct `Card` or `Container` surfaces.
- Migrating screens without canonical primitives would move duplication from one file to another instead of removing it.

Alternatives considered:
- Migrate screens one-by-one with inline styling: rejected because it would make consistency depend on reviewer discipline rather than shared APIs.
- Restrict the shared package to theme tokens only: rejected because structural duplication is already present and would remain unresolved.

### Decision: Preserve app-owned orchestration and route logic
Apps will keep their router configuration, navigation callbacks, provider wiring, repository access, and workflow decisions. The shared package will expose styling, composition, and callback-driven widgets only.

Rationale:
- This matches the existing repository architecture and the current `shared-flutter-component-library` boundaries.
- It reduces migration risk by limiting changes to presentation contracts.

Alternatives considered:
- Move navigation behavior into the shared package: rejected because app flows differ and should remain decoupled from reusable UI.

### Decision: Roll out the design in four phases
1. Theme foundation in `design_system_flutter`.
2. Shared primitive expansion in `design_system_flutter`.
3. App-by-app adoption across all full-screen routes.
4. Validation and cleanup of leftover local styling.

Rationale:
- The change touches every Flutter app and needs a controlled sequence.
- Shared foundation work must land before page migration to avoid temporary parallel systems.

Alternatives considered:
- Big-bang migration across all files at once: rejected because it would be difficult to validate and would increase regression risk.

## Risks / Trade-offs

- [Risk] Shared primitives may become too rigid for specialized screens such as clinical chat or report rendering. → Mitigation: define slot-based composition APIs and optional variants rather than hardcoding workflow behavior.
- [Risk] The migration may leave hidden hardcoded colors or legacy borders in lower-traffic screens. → Mitigation: add explicit audit tasks for raw `Colors.*`, `Card`, and local shell duplication before considering the rollout complete.
- [Risk] Introducing Manrope and richer surface styling may affect rendering or bundle size. → Mitigation: keep typography and decoration assets centralized in `design_system_flutter` and validate each app with `flutter analyze`.
- [Risk] Visual modernization could accidentally change usability or accessibility expectations. → Mitigation: preserve existing flow semantics, maintain AA contrast targets, and encode focus/feedback states in shared components instead of per-screen overrides.

## Migration Plan

1. Replace the current light-theme foundation in `packages/design_system_flutter` with the new shared dark token system and theme entry points.
2. Introduce or refactor shared widgets needed to express the new visual language consistently, including shell, navigation, panel, form, and feedback primitives.
3. Migrate `survey-patient` screen-by-screen onto the new primitives, with emphasis on public screening, notice, instructions, report, and thank-you flows.
4. Migrate `survey-frontend` screen-by-screen onto the new primitives, including auth, demographics, survey, report, access-link, profile, and settings surfaces.
5. Migrate `clinical-narrative` screen-by-screen onto the new primitives, including auth, chat, narrative, report, demographics, and thank-you surfaces.
6. Migrate `survey-builder` screen-by-screen onto the new primitives, including list, form, prompt, persona, and editor screens.
7. Remove obsolete local wrappers and styling that duplicate shared functionality after each app is fully adopted.
8. Run `flutter analyze` in each affected Flutter app and update shared widget tests where component behavior changed.

## Open Questions

- Whether the canonical theme API should expose only a dark theme or also keep a deprecated light entry point temporarily during migration.
- Which existing screen-specific widgets in the chat and report flows need dedicated shared variants versus flexible base primitives.
- Whether the design documentation should be mirrored into package-level developer docs or referenced directly from `docs/lapan-design/lapan-design.md`.
