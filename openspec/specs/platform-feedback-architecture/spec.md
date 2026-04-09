# platform-feedback-architecture Specification

## Purpose
Formalizes the implementation and usage rules for the LAPAN platform's feedback and notification system components, including `DsToast`, `DsMessageBanner`, `DsDialog`, and `DsInlineMessage`, ensuring consistency and accessibility.

## Requirements

### Requirement: Transient Confirmation Toasts
The system SHALL use `DsToast` exclusively for confirmation of successfully completed actions and lightweight "undo" actions. These messages SHALL be transient and auto-dismiss after a short period (max 4s).

#### Scenario: Save confirmation
- **WHEN** the user saves a configuration
- **THEN** the system SHALL display a `DsToast` with success severity: "Alterações salvas."

### Requirement: Persistent Contextual Banners
The system SHALL use `DsMessageBanner` for providing persistent contextual information, degraded state warnings, or clinical/legal risks that do not interrupt the current flow.

#### Scenario: Offline mode warning
- **WHEN** connection to the server is lost
- **THEN** the system SHALL display a `DsMessageBanner` at the top of the relevant section: "Você está offline. Algumas funções podem estar limitadas."

### Requirement: Blocking Decision Dialogs
The system SHALL use `DsDialog` only for actions that require an explicit user decision before proceeding, especially for destructive or irreversible actions. These dialogs SHALL support severity styling (CR-UX-001).

#### Scenario: Confirm questionnaire deletion
- **WHEN** the user clicks "Excluir Questionário"
- **THEN** the system SHALL open a `DsDialog` with `Warning` severity
- **AND** include explicit verbs: "Excluir" (destructive) and "Cancelar".

### Requirement: Contextual Inline Validation
Form validation failures SHALL be presented contextually through `DsInlineMessage` (near the relevant input) or in a validation summary, and SHALL NEVER be presented exclusively via `DsToast` or a global banner.

#### Scenario: Attempt to submit form with errors
- **WHEN** the user attempts to submit a form with missing required fields
- **THEN** the system SHALL highlight the fields with `DsInlineMessage` and prevent submission.
