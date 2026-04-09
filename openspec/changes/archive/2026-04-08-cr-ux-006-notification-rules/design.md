## Context
The LAPAN platform already includes the `DsFeedbackMessage` model (CR-UX-001) and the `DsFeedbackBanner` and `DsInlineFeedback` components. However, the naming is inconsistent with industry standards, and the use of raw `SnackBar` and `DsDialog` without severity results in breaks in the visual experience.

## Decisions

### 1. Strategic Renaming
- **DsFeedbackBanner** -> **DsMessageBanner**: Focused on persistent page or section messages.
- **DsInlineFeedback** -> **DsInlineMessage**: Focused on contextual feedback for forms (CR-UX-003).

### 2. Formalization of `DsToast`
- **Rationale**: Native Snackbars are difficult to style and lose accessibility if manually configured. `DsToast` will be the official wrapper that automatically injects the severity theme and icons from CR-UX-001.
- **Constraint**: Toasts SHALL be used only for transient successes (< 4s) or confirmations of lightweight actions (e.g., undo).

### 3. Severity in `DsDialog`
- **Rationale**: Critical dialogs (e.g., delete patient, fatal AI error) should carry the visual weight of severity.
- **Implementation**: `DsDialog` will now accept an optional `severity` parameter that will color the header and include the corresponding icon (info, success, warning, error), following the CR-UX-001 palette.

### 4. Hierarchy Rules (Governance)
| Scenario | Feedback Type | Suggested Severity |
|----------|---------------|-------------------|
| Field Validation Error | InlineMessage | Error |
| Success after Save | Toast | Success |
| Redirection (Wayfinding) | MessageBanner | Info |
| Destructive Confirmation | Dialog | Warning |
| Fatal System Failure | Dialog | Error |

## Implementation Strategy
1. Update `packages/design_system_flutter/lib/widgets/ds_feedback.dart` with renames and the new `DsToast`.
2. Refactor `ds_dialog.dart` to support `DsStatusType`.
3. Update exports to maintain compatibility (deprecated aliases if necessary).
