## ADDED Requirements
### Requirement: Perceived Performance
The system SHALL keep UI response times within 250ms for critical interactions.

#### Scenario: Message send
- **WHEN** the clinician sends a message
- **THEN** the message appears in the UI immediately and without noticeable blocking

### Requirement: Voice Button Response Time
The system SHALL enter the recording state within 150ms after user action.

#### Scenario: Start recording
- **WHEN** the clinician activates the voice button
- **THEN** the recording state is shown without noticeable delay
