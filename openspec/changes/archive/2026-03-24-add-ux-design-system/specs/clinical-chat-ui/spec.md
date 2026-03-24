## ADDED Requirements
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
