# error-handling Specification

## Purpose
Standardize how technical and functional errors are mapped, reported, and recovered from across the LAPAN Survey Platform, prioritizing user-friendly guidance in Brazilian Portuguese (pt-BR).

## Requirements

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

### Requirement: Human-Readable Error Messages
The system SHALL replace technical error strings (e.g., "HTTP 500", "ConnectionTimeout") with user-friendly explanations in Brazilian Portuguese (pt-BR) that describe the problem and actions the user can take.

#### Scenario: Internal server error
- **WHEN** a 500 error occurs on the backend
- **THEN** the system SHALL display: "Não foi possível completar esta ação agora. Nossos sistemas estão temporariamente indisponíveis. Tente novamente em alguns instantes."
- **AND** provide a "Tentar Novamente" (Retry) button.

### Requirement: AI Processing Error Handling
The system SHALL handle AI generation and analysis failures with clear pt-BR messages and distinguish between transient (retryable) and permanent errors.

#### Scenario: Transient AI failure
- **WHEN** a temporary failure occurs in AI processing (e.g., timeout)
- **THEN** the system SHALL display "Não foi possível concluir agora. Tente novamente em alguns instantes." and offer a `Tentar Novamente` button.

#### Scenario: Persistent AI failure
- **WHEN** the AI fails repeatedly or due to a content error (e.g., insufficient data)
- **THEN** the system SHALL display "Não conseguimos gerar a análise automática para este caso." and allow the user to continue manually or submit without the AI report.

### Requirement: AI Partial Results Handling
The system SHALL allow the user to utilize partial results or access the original data when full AI processing is not completed.

#### Scenario: Access to original data after AI failure
- **WHEN** AI report generation fails
- **THEN** the system SHALL ensure the user can still view and download the questionnaire responses.

