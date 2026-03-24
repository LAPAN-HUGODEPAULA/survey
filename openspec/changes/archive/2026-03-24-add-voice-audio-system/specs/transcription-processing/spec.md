## ADDED Requirements
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
