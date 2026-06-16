# Voice Capture & Transcription Processing Specification

## Purpose
Consolidates audio recording, retention policies, playback UI, local transcription preview, and FastAPI transcription backend endpoints.

## Requirements
### Requirement: Microphone Permission and Availability
The system SHALL request microphone permission and clearly report unavailability before starting recording.

#### Scenario: Permission granted
- **WHEN** the clinician activates the voice button
- **THEN** the browser requests permission and recording can start with a visible recording indicator

#### Scenario: Permission denied
- **WHEN** the clinician denies permission
- **THEN** the system shows an English message, links to browser settings, and offers text input

### Requirement: Configurable Audio Recording
The system SHALL record audio in the browser with configurable format, sample rate, and max duration.

#### Scenario: Start recording with parameters
- **WHEN** recording starts
- **THEN** audio is captured according to configured parameters (format, rate, channels) and the settings are logged for the session

#### Scenario: Duration limit
- **WHEN** the maximum recording duration is reached
- **THEN** the system stops capture, notifies the clinician, and keeps the captured audio for review

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

### Requirement: Provider-Agnostic Transcription API
The system SHALL process audio on the server through a provider-decoupled transcription interface selected by configuration.

#### Scenario: Select provider by configuration
- **WHEN** audio is sent for transcription
- **THEN** the backend uses the configured provider without changing the response contract

### Requirement: Response with Quality Metadata
The system SHALL return final text with confidence metadata, segments, and processing time.

#### Scenario: Metadata response
- **WHEN** final transcription completes
- **THEN** the response includes text, confidence, segments, total time, and detected language

### Requirement: Language and Clinical Mode Parameterization
The system SHALL allow configuring language, confidence thresholds, and clinical mode per request or via default configuration.

#### Scenario: Custom parameters
- **WHEN** the client sends language and clinical mode parameters
- **THEN** processing uses those parameters, records them in the result, and returns any warnings

### Requirement: Recorded Audio Playback
The system SHALL allow playing back recorded audio before sending it for final transcription.

#### Scenario: Playback before send
- **WHEN** recording ends
- **THEN** the clinician can play, pause, and seek the audio with visible duration

### Requirement: Accessible Playback Controls
The system SHALL provide playback controls compatible with keyboard and touch.

#### Scenario: Keyboard control
- **WHEN** the clinician uses the keyboard to control playback
- **THEN** the system responds to commands defined in the design system and announces state changes

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
