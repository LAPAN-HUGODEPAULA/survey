## Why
With the consolidation of the **Shared Feedback (CR-UX-001)** model and the lifecycles for **Forms (CR-UX-003)**, **Wayfinding (CR-UX-004)**, and **AI (CR-UX-005)**, the LAPAN platform now possesses the base components but still lacks a clear grammar of use. Currently, notifications, snackbars, and dialogs are used inconsistently, which compromises accessibility and the predictability of the experience.

## What Changes
- **Container Taxonomy**: Formalization of the rules for choosing between `DsToast`, `DsMessageBanner`, `DsInlineMessage`, and `DsDialog`.
- **Design System Evolution**: Refactoring and renaming existing components to align with industry standards (`DsFeedbackBanner` -> `DsMessageBanner`, `DsInlineFeedback` -> `DsInlineMessage`).
- **DsToast Formalization**: Total replacement of direct `SnackBar` usage with the `DsToast` component, ensuring automatic application of severity and accessibility.
- **DsDialog with Severity**: Updating the `DsDialog` component to support colors and icons based on `DsStatusType` (CR-UX-001), ensuring visual consistency in critical actions.
- **Feedback Hierarchy**: Ensuring that critical messages (errors) are never ephemeral, by mandatory use of `Banners` or `Dialogs`.

## Capabilities
### New Capabilities
- `platform-feedback-governance`: Semantic rules that link the type of event (error, success, info) to the correct visual container, respecting Wayfinding patterns (CR-UX-004).

### Modified Capabilities
- `shared-feedback-messaging`: Expansion of the feedback contract to include support for dialogs and persistence rules.

## Impact
- `packages/design_system_flutter`: Component renaming, `DsDialog` update, and `DsToast` formalization.
- All frontend applications: Refactoring of success, error, and confirmation flows to follow the new governance standards.
