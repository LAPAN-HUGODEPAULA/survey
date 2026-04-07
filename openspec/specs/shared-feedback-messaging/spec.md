# shared-feedback-messaging Specification

## Purpose
TBD - created by archiving change cr-ux-001-standardize-feedback-severity-icons-and-message-structure. Update Purpose after archive.
## Requirements
### Requirement: Platform feedback severity taxonomy
The LAPAN Flutter apps MUST classify user-facing feedback with a canonical shared severity taxonomy of `info`, `success`, `warning`, and `error`, with severity meaning preserved consistently across applications.

#### Scenario: Render the same severity in different apps
- **WHEN** `survey-patient`, `survey-frontend`, `survey-builder`, or `clinical-narrative` presents a user-facing feedback message
- **THEN** the message MUST declare one canonical severity from the shared taxonomy
- **AND** that severity MUST map to a consistent visual and semantic meaning in every app

### Requirement: Structured feedback message content
The platform MUST represent user-facing feedback through a structured message contract that supports a severity, icon, title, body text, and optional user actions.

#### Scenario: Present a recoverable user-facing error
- **WHEN** a screen needs to tell the user that an action failed but can be retried
- **THEN** the message MUST include an error severity, a visible icon, a short title, and body text that explains what happened
- **AND** the message MUST be able to expose at least one action such as retry, review, undo, or dismiss when the flow supports it

### Requirement: Feedback placement MUST match message purpose
The platform MUST use different feedback containers for different user needs instead of routing every status through the same presentation surface.

#### Scenario: Present validation and page-level feedback in the same flow
- **WHEN** a user triggers a field-level validation error and a page-level informational state in the same screen
- **THEN** the validation error MUST be presented inline or in a validation summary near the relevant inputs
- **AND** the page-level informational state MUST be presented through a non-inline container such as a banner, page state, or other persistent contextual surface
- **AND** transient snackbars or toasts MUST NOT be the only surface for important validation guidance

### Requirement: Feedback MUST remain perceivable without color alone
The platform MUST communicate feedback severity through iconography, text, and semantics in addition to color.

#### Scenario: User perceives a warning state without relying on color
- **WHEN** a warning or error message is shown in a Flutter app
- **THEN** the message MUST include visible text and a visible status icon in addition to its tonal color treatment
- **AND** the meaning of the message MUST remain understandable for users who cannot reliably distinguish color

### Requirement: Nonblocking status updates MUST support assistive technologies
The platform MUST support accessible announcement behavior for status messages that do not move focus.

#### Scenario: A nonblocking status update appears after a user action
- **WHEN** a screen shows a success, warning, info, or error update without opening a dialog or moving focus
- **THEN** the feedback surface MUST support status-message semantics or live-region behavior so assistive technologies can announce the update
- **AND** the screen MUST NOT require the user to discover the update only by visual scanning

