# Design System Flutter

## Feedback and Notification Rules

The design system uses a shared severity model (`info`, `success`, `warning`, `error`) with container-specific guidance:

- `DsInlineMessage`: contextual feedback inside forms and local flows.
- `DsMessageBanner`: persistent page or section messages.
- `showDsToast(...)`: short transient confirmations (up to 4 seconds).
- `DsDialog(severity: ...)`: blocking decisions that require explicit user action.

### Accessibility

- Keep severity icon + text together; never rely only on color.
- `DsToast` and other shared feedback surfaces expose live-region semantics for screen readers.
- Use contrast-safe foreground/background pairs from the theme container palette.

### Migration Compatibility

Deprecated aliases are still available temporarily:

- `DsFeedbackBanner` -> `DsMessageBanner`
- `DsInlineFeedback` -> `DsInlineMessage`
- `showDsFeedbackSnackBar(...)` -> `showDsToast(...)`
