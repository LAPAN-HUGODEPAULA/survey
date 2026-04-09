# Shared Feedback Messaging Standards

This document defines the approved feedback model introduced by `cr-ux-001-standardize-feedback-severity-icons-and-message-structure`.

## Severity Model

- `info`: neutral guidance, progress, or contextual updates that do not indicate success or failure.
- `success`: a user action completed as expected.
- `warning`: the flow can continue, but the user should review or correct something.
- `error`: the current action failed or requires intervention before the user can proceed.

## Canonical Structure

Every important user-facing feedback message should include:

- an icon that matches the severity
- a short title
- a clear body message
- optional actions when the user can retry, dismiss, undo, or review the issue

## Approved Containers

- `DsValidationSummary`: for form-level validation that aggregates multiple problems
- `DsInlineMessage`: for section-level and conversational feedback inside the current context
- `DsMessageBanner`: for persistent page-level or panel-level status messages
- `showDsToast(...)`: only for lightweight confirmations and transient non-blocking updates (max 4 seconds)
- `DsDialog(severity: ...)`: for blocking decisions and destructive confirmations that require explicit user action

## Placement Rules

- Do not rely on snackbars alone for required validation guidance.
- Keep validation feedback close to the affected fields and add a summary when multiple errors exist.
- Use banners for save, load, warning, fallback, and server-response states that the user may need to read carefully.
- Use inline feedback for clinical assistant status, voice capture feedback, and other in-context status changes.
- Use warning or error severity dialogs for destructive and irreversible actions.
- Prefer explicit action verbs in dialogs (`Excluir`, `Descartar rascunho`, `Encerrar sessão`) instead of generic labels.

## Accessibility

- Do not use color as the only severity indicator.
- Always include visible text and an icon.
- Keep non-blocking status feedback in live regions through the shared components so assistive technologies can announce updates.

## Brazilian Portuguese Copy

- All user-facing copy must use correct Brazilian Portuguese accentuation and spelling.
- During implementation review, check titles, bodies, button labels, validation messages, and status text for missing diacritics such as `ação`, `informação`, `relatório`, `avaliação`, `sessão`, `clínico`, and `configurações`.
