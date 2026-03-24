## ADDED Requirements
### Requirement: Microphone Error Handling
The system SHALL map common microphone errors to English messages and offer recovery.

#### Scenario: Permission denied
- **WHEN** the browser returns a permission error
- **THEN** the system shows guidance, links to browser settings, and enables text input

#### Scenario: Microphone unavailable
- **WHEN** no audio device is detected
- **THEN** the system reports the issue in English and suggests trying again

### Requirement: Transcription Error Handling
The system SHALL handle upload and transcription failures with retries and a manual edit alternative.

#### Scenario: Upload failure
- **WHEN** the audio upload fails due to a network error
- **THEN** the system retries according to the configured policy and shows progress

#### Scenario: Transcription failure
- **WHEN** the server cannot transcribe
- **THEN** the system allows manual submission of edited text and captures a failure reason
