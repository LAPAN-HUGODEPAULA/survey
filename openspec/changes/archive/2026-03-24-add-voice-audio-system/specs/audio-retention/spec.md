## ADDED Requirements
### Requirement: Audio Retention Policy
The system SHALL delete the audio file from the server after final transcription completes.

#### Scenario: Deletion after transcription
- **WHEN** the final transcription is returned successfully
- **THEN** the audio is removed from server storage within the configured deadline and the deletion is logged

### Requirement: Retention Transparency
The system SHALL inform the clinician that only text will be retained and the audio will be discarded.

#### Scenario: Inform retention policy
- **WHEN** the clinician starts the voice flow
- **THEN** the system shows a retention message in English and links to policy details
