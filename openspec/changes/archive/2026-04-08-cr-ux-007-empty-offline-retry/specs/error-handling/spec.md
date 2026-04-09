## MODIFIED Requirements

### Requirement: Microphone Error Handling
The system SHALL map common microphone errors into user-friendly messages in Brazilian Portuguese (pt-BR) and offer recovery paths (Retry).

#### Scenario: Permission denied
- **WHEN** the browser returns a microphone permission error
- **THEN** the system SHALL display guidance in pt-BR, a link to browser settings, and enable alternative text input.

#### Scenario: Microphone unavailable
- **WHEN** no audio device is detected
- **THEN** the system SHALL inform the user in pt-BR and suggest "Tentar Novamente" (Retry).

### Requirement: Transcription Error Handling
The system SHALL handle upload and transcription failures with standardized retries and a manual editing fallback.

#### Scenario: Upload failure
- **WHEN** the audio upload fails due to a network error
- **THEN** the system SHALL retry according to policy, display progress, and offer a manual "Tentar Novamente" button in pt-BR.

#### Scenario: Transcription failure
- **WHEN** the server fails to transcribe the audio
- **THEN** the system SHALL allow the user to manually write clinical notes and capture the failure reason.

## ADDED Requirements

### Requirement: Human-Readable Error Messages
The system SHALL replace technical error strings (e.g., "HTTP 500", "ConnectionTimeout") with user-friendly explanations in Brazilian Portuguese (pt-BR) that describe the problem and actions the user can take.

#### Scenario: Internal server error
- **WHEN** a 500 error occurs on the backend
- **THEN** the system SHALL display: "Não foi possível completar esta ação agora. Nossos sistemas estão temporariamente indisponíveis. Tente novamente em alguns instantes."
- **AND** provide a "Tentar Novamente" (Retry) button.
