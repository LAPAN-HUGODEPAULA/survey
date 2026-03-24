## ADDED Requirements
### Requirement: Real-Time Transcription Preview
The system SHALL display a preliminary transcription in the browser during recording when local recognition is available.

#### Scenario: Preview available
- **WHEN** recording is active and local recognition is available
- **THEN** the preliminary text appears in real time in the input area with a "preview" indicator

#### Scenario: Preview unavailable
- **WHEN** the browser does not support local recognition
- **THEN** the system informs the limitation in English and continues recording without preview

### Requirement: Edit Preview Before Send
The system SHALL allow the clinician to edit the preliminary text before sending it for final transcription.

#### Scenario: Edit text
- **WHEN** recording ends
- **THEN** the preliminary text remains editable until submission and the clinician can clear it
