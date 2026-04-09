## ADDED Requirements

### Requirement: Offline Status Banner
The system SHALL display a persistent `DsMessageBanner` (CR-UX-006) when server connectivity is lost, explaining the current status and ensuring data safety.

#### Scenario: Connection loss during active use
- **WHEN** server connectivity is interrupted
- **THEN** the system SHALL display a `DsMessageBanner` with `warning` severity at the top: "Você está offline. Suas alterações serão salvas localmente até a conexão voltar."
- **AND** use the Brazilian Portuguese (pt-BR) language for the message content.

### Requirement: Global Retry Control
Recoverable network or loading failures SHALL offer a visible and consistent "Retry" (Tentar Novamente) control within the error container (CR-UX-001).

#### Scenario: Questionnaire loading failure
- **WHEN** a questionnaire fails to load due to a network error
- **THEN** the system SHALL display a `DsFeedbackMessage` with `error` severity
- **AND** include a primary action button labeled "Tentar Novamente".
