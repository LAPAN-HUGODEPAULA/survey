## ADDED Requirements

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
