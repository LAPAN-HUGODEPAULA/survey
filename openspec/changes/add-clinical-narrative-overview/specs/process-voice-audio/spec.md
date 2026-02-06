## ADDED Requirements
### Requirement: Browser Voice Capture
The system SHALL allow recording audio in the browser with start, pause, and stop controls.

#### Scenario: Start recording
- **WHEN** the clinician starts recording
- **THEN** the system captures audio locally and shows the recording state

### Requirement: Hybrid Transcription
The system SHALL show a preliminary transcription in the browser and generate a final transcription on the server.

#### Scenario: Finish transcription
- **WHEN** recording ends
- **THEN** the system sends audio for final processing and replaces the preliminary transcription
