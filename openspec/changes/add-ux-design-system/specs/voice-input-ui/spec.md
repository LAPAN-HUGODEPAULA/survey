## ADDED Requirements
### Requirement: Voice Button States
The system SHALL visually indicate permission, recording, processing, and error states.

#### Scenario: Recording state
- **WHEN** recording is active
- **THEN** the button shows the recording state with clear feedback and a stop control

### Requirement: Recording Indicator
The system SHALL show duration and audio feedback during recording.

#### Scenario: Active recording
- **WHEN** the clinician records audio
- **THEN** the system shows a running duration and an audio activity indicator

### Requirement: Transcription Preview
The system SHALL display real-time transcription preview when available and allow edits before sending.

#### Scenario: Active preview
- **WHEN** recognition is available
- **THEN** preliminary text appears during recording and can be edited
