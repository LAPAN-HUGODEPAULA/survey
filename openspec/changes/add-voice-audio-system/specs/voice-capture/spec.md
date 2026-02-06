## ADDED Requirements
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
