## MODIFIED Requirements

### Requirement: Human-Readable Error Messages
The system SHALL replace technical error strings (e.g., "HTTP 500", "ConnectionTimeout") with user-friendly explanations in Brazilian Portuguese (pt-BR) that describe the problem and actions the user can take. API responses MUST use the standardized frontend-safe error object defined in `frontend-safe-error-contracts`.

#### Scenario: Internal server error
- **WHEN** a 500 error occurs on the backend
- **THEN** the system SHALL return a structured error response with `code: INTERNAL_SERVER_ERROR`
- **AND** the `userMessage` SHALL display: "Não foi possível completar esta ação agora. Nossos sistemas estão temporariamente indisponíveis. Tente novamente em alguns instantes."
- **AND** the `retryable` field MUST be set to `true`.

### Requirement: AI Processing Error Handling
The system SHALL handle AI generation and analysis failures with clear pt-BR messages and distinguish between transient (retryable) and permanent errors using the standardized error contract.

#### Scenario: Transient AI failure
- **WHEN** a temporary failure occurs in AI processing (e.g., timeout)
- **THEN** the system SHALL return an error object with `code: AI_TIMEOUT` and `retryable: true`
- **AND** the system SHALL display "Não foi possível concluir agora. Tente novamente em alguns instantes." and offer a `Tentar Novamente` button.

#### Scenario: Persistent AI failure
- **WHEN** the AI fails repeatedly or due to a content error (e.g., insufficient data)
- **THEN** the system SHALL return an error object with `code: AI_ANALYSIS_FAILED` and `retryable: false`
- **AND** the system SHALL display "Não conseguimos gerar a análise automática para este caso." and allow the user to continue manually or submit without the AI report.
