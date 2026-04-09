## Context

The LAPAN Flutter apps already share a design-system package in `packages/design_system_flutter`, but user-facing feedback is still fragmented. Today the platform mixes:

- raw `SnackBar` messages
- app-local banners and panels
- `DsStatusChip` and `DsStatusIndicator`
- `DsLoading`, `DsError`, and `DsEmpty`
- auth-specific `_DsFeedbackBanner`

This produces three problems:

1. Users cannot rely on one stable feedback language across apps.
2. Severity is not always recognizable from icon, wording, and semantics together.
3. Shared UI has no canonical data model for messages, so each feature reinvents placement, structure, and copy behavior.

The repository already contains a matching severity enum, `DsStatusType`, with `neutral`, `info`, `success`, `warning`, and `error`. This makes the change architectural but low-risk: the platform does not need a second severity model, only a canonical feedback system built on top of the one it already has.

Stakeholders:

- patients using `survey-patient`
- clinicians and screeners using `survey-frontend` and `clinical-narrative`
- administrators using `survey-builder`
- contributors maintaining the shared Flutter library

Constraints:

- all UI remains in Brazilian Portuguese
- shared UI must stay in `packages/design_system_flutter`
- apps must keep ownership of routing, repositories, and side effects
- this change must not depend on backend contract redesign

## Goals / Non-Goals

**Goals:**

- Define one canonical severity and message structure for Flutter feedback surfaces.
- Add shared feedback primitives to `packages/design_system_flutter`.
- Standardize feedback behavior across auth, patient flow, clinical chat, and builder surfaces.
- Improve accessibility by ensuring severity is perceivable without color alone and by supporting status-message semantics.
- Preserve app-owned orchestration while removing duplicated feedback presentation logic.

**Non-Goals:**

- Redesign backend error payloads or add new API progress contracts.
- Solve AI stage-progress UX beyond the surfaces needed to support this feedback model.
- Rewrite every piece of microcopy in the platform in this change.
- Replace every existing snackbar in one atomic migration if a phased rollout is safer.

## Decisions

### Decision: Reuse `DsStatusType` as the canonical severity model

The platform will use the existing `DsStatusType` enum as the shared severity taxonomy for feedback messaging.

Rationale:

- The enum already exists in the shared package and matches the required severity levels.
- Reusing it avoids parallel concepts for “status” and “feedback severity”.
- Existing chips and status indicators can be aligned with the same meaning model.

Alternatives considered:

- Introduce a new `DsFeedbackSeverity` enum.
  - Rejected because it duplicates the same domain concept and would create mapping overhead.

### Decision: Introduce a shared feedback data model plus container-specific widgets

The change will introduce a canonical feedback model in `packages/design_system_flutter`, backed by container-specific renderers such as inline messages, banners, summaries, and toast/snackbar adapters.

Expected model fields:

- severity
- title
- body
- icon override
- primary action
- secondary action
- dismissibility
- persistence
- semantics/live-region behavior

Rationale:

- A single model lets the same content be rendered in different surfaces without rewriting logic.
- Container-specific widgets preserve correct placement for validation summaries, page banners, and transient toasts.
- Apps can keep domain decisions while delegating presentation structure to the shared library.

Alternatives considered:

- Create one universal feedback widget for every context.
  - Rejected because field errors, page banners, and snackbars have different interaction and layout requirements.

### Decision: Keep placement rules as design-system guidance plus component affordances

This change will encode message placement through shared component affordances and project documentation, but it will not attempt to enforce placement through a runtime policy engine.

Rationale:

- Placement decisions remain contextual to the screen and task.
- The design system can still steer correct usage by providing purpose-built components:
  - inline validation
  - error summary
  - persistent banner
  - transient toast/snackbar adapter
  - confirmation dialog pattern

Alternatives considered:

- Central runtime dispatcher that forces every message through one route.
  - Rejected because it adds complexity and weakens local composition in Flutter screens.

### Decision: Migrate incrementally by surface family

The rollout will happen in this order:

1. shared feedback primitives in `packages/design_system_flutter`
2. professional auth surfaces
3. patient survey flow surfaces
4. clinical chat surfaces
5. survey-builder administrative surfaces

Rationale:

- Auth has the clearest current gap and the simplest feedback states.
- Patient and builder flows currently overuse raw snackbars and benefit quickly.
- Clinical chat is richer and should migrate after the shared model stabilizes.

Alternatives considered:

- Single-shot migration across all apps.
  - Rejected because it increases regression risk and makes review harder.

### Decision: Keep this change frontend-focused

This change will standardize presentation and interaction behavior without requiring new backend response shapes.

Rationale:

- The feedback model can be adopted immediately over existing frontend and repository logic.
- API contract redesign belongs to a later change (`CR-UX-012` in the planning document), not to this one.

Alternatives considered:

- Bundle frontend feedback standardization with backend error-contract redesign.
  - Rejected because it broadens scope and delays visible UX improvements.

## Risks / Trade-offs

- [Risk] Shared components may become too generic to be pleasant to use in real screens.  
  → Mitigation: keep a small canonical model, expose composition slots, and migrate real app surfaces during the same change.

- [Risk] Existing screens may keep mixing old and new feedback patterns during rollout.  
  → Mitigation: explicitly migrate the four targeted surface families and document the old patterns as deprecated.

- [Risk] Severity semantics may drift if copy and icon choices are left entirely to each app.  
  → Mitigation: define canonical icon mapping, default titles, and placement rules in the shared package and spec text.

- [Risk] Some snackbar use cases may still be appropriate, creating ambiguity.  
  → Mitigation: document the allowed snackbar use cases narrowly: transient confirmation, undo, and lightweight non-blocking feedback.

- [Risk] Screen-reader treatment may remain inconsistent if message semantics are optional everywhere.  
  → Mitigation: require live-region capable shared components for non-focus-taking status updates.

## Migration Plan

1. Add the shared feedback model and canonical renderers to `packages/design_system_flutter`.
2. Update shared auth widgets to replace `_DsFeedbackBanner` with the canonical shared feedback surface.
3. Update patient-flow pages in `survey-patient` and `survey-frontend` to replace raw snackbar-only validation and ad-hoc status panels where this change applies.
4. Update `clinical-narrative` assistant alerts and status surfaces to use typed shared feedback presentation.
5. Update `survey-builder` list and form flows to show in-context standardized feedback.
6. Add tests for severity rendering, icon mapping, and key migrated surfaces.
7. Document the new feedback model and mark old ad-hoc patterns as deprecated.

Rollback strategy:

- Because the change is component-based, rollback can revert individual app migrations first while preserving the shared package additions.
- If the shared primitives cause regressions, apps can temporarily fall back to previous local surfaces while the canonical components are corrected.

## Open Questions

- Should the shared package provide default pt-BR titles for severity classes, or should every screen always provide explicit titles?
- Should the snackbar/toast adapter live in the shared package as a presenter helper, or should the package only provide styled content widgets and let apps own presentation calls?
- Should `neutral` remain available for informational chips only, or should it also be supported by the broader feedback message model?
