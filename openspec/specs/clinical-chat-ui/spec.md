# clinical-chat-ui Specification

## Purpose
TBD - created by archiving change add-ux-design-system. Update Purpose after archive.
## Requirements
### Requirement: Conversational Message List
The system SHALL display messages in chronological order with clear author identification, timestamps, and scrollable history that keeps the latest content visible.

#### Scenario: Show history and latest
- **WHEN** an active session is opened
- **THEN** the system presents history in order, labels authors, and scrolls to the newest message

### Requirement: Persistent Input Area
The system SHALL keep the input area visible during the conversation with text, keyboard send, and voice toggle support.

#### Scenario: Send message
- **WHEN** the clinician types and presses Enter or taps Send
- **THEN** the message appears in the list and focus remains on the input

### Requirement: Message Actions
The system SHALL offer message actions such as copy, edit, and delete for clinician-authored messages.

#### Scenario: Edit clinician message
- **WHEN** the clinician selects edit on their own message
- **THEN** the system allows adjusting the content before resending while preserving message history

### Requirement: Clinical chat MUST distinguish typed feedback surfaces
The `clinical-narrative` conversation UI MUST distinguish informational, warning, and error feedback consistently across assistant status, alerts, and insight surfaces.

#### Scenario: Assistant feedback is shown during a clinical conversation
- **WHEN** the conversation UI shows an assistant alert, system status, or typed insight
- **THEN** the interface MUST render it with a defined severity and a consistent iconographic treatment
- **AND** the user MUST be able to understand whether the content is informational, cautionary, or blocking

#### Scenario: Nonblocking conversation feedback is announced accessibly
- **WHEN** a status update appears in the chat screen without moving focus
- **THEN** the update MUST support an accessible status announcement mechanism
- **AND** it MUST remain visually consistent with the shared feedback model

