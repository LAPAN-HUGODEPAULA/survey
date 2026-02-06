## ADDED Requirements
### Requirement: Message Types
The system SHALL support distinct message types for user input, AI responses, system notices, suggestions, and document previews.

#### Scenario: Render message types
- **WHEN** messages are displayed in the conversation
- **THEN** each type is rendered with a distinct visual treatment

### Requirement: Message Structure
The system SHALL store messages with identifiers, session linkage, content, timestamps, and optional metadata.

#### Scenario: Persist message
- **WHEN** a message is sent
- **THEN** it is stored with a unique ID and server timestamp

### Requirement: Message Actions
The system SHALL allow edit, regenerate, copy, and soft delete actions for messages when applicable.

#### Scenario: Edit user message
- **WHEN** a clinician edits a message before AI response
- **THEN** the system updates the message and preserves edit history
