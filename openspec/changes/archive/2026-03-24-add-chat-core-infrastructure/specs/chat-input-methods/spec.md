## ADDED Requirements
### Requirement: Text Input
The system SHALL provide a text input area for clinician messages.

#### Scenario: Send text message
- **WHEN** the clinician types a message and submits
- **THEN** the system sends the message into the conversation

### Requirement: Voice Mode Toggle
The system SHALL provide a toggle to switch between text and voice input modes.

#### Scenario: Toggle input mode
- **WHEN** the clinician switches input mode
- **THEN** the system updates the input controls to match the selected mode

### Requirement: Quick Actions
The system SHALL provide quick actions for common workflows such as generating documents and ending consultations.

#### Scenario: End consultation action
- **WHEN** the clinician triggers the end consultation action
- **THEN** the system asks for confirmation before completing the session
