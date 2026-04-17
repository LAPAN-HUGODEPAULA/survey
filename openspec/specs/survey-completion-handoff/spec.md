# survey-completion-handoff Specification

## Purpose
TBD - created by archiving change cr-ux-010-improve-survey-completion. Update Purpose after archive.
## Requirements
### Requirement: Three-Step Survey Completion Handoff
The system SHALL implement a visually distinct three-step handoff sequence upon survey submission to guide the user from completion to results.

#### Scenario: Sequence of stages
- **WHEN** the user submits a survey
- **THEN** the system SHALL display the sequence: "Responses Registered" (Respostas registradas), then "Analysis in Progress" (Análise preliminar em preparo), and finally "Report Ready" (Relatório disponível)
- **AND** EACH stage MUST be clearly labeled in Brazilian Portuguese (pt-BR).

### Requirement: Visual Separation of System and Clinical Content
The system SHALL use distinct visual containers to separate system status messages (e.g., progress, saving) from clinical feedback or report content.

#### Scenario: Separation on summary page
- **WHEN** the user is on the assessment summary page
- **THEN** system status messages (like "Relatório sendo gerado...") MUST use a functional/status container
- **AND** clinical results or patient notes MUST use a content/clinical container (e.g., card with different background or border).

### Requirement: Delayed Reference ID Presentation
The system SHALL only display the assessment reference/protocol ID after providing a plain-language explanation of its purpose.

#### Scenario: Reference ID with context
- **WHEN** the survey is successfully saved and the ID is generated
- **THEN** the system SHALL first display: "Sua avaliação foi salva. Este código identifica o atendimento para futuras consultas:"
- **AND** then display the reference ID.

### Requirement: Empathetic Effort Acknowledgment
The system SHALL include microcopy that acknowledges the user's effort and contribution upon survey completion.

#### Scenario: Acknowledgment in patient flow
- **WHEN** the patient completes the screening
- **THEN** the system SHALL display: "Obrigado por sua colaboração. Suas respostas ajudam a construir um olhar mais cuidadoso para sua saúde."

### Requirement: Optional Enrichment Guidance
The system SHALL provide clear guidance for optional demographic or clinical enrichment steps, explaining the benefits of providing more data.

#### Scenario: Optional demographics fork
- **WHEN** the basic screening is complete and optional demographics are available
- **THEN** the system SHALL explain: "Estas informações opcionais ajudam em pesquisas estatísticas, mas você pode pular esta etapa se preferir."

### Requirement: Survey completion handoff MUST use explicit access-point keys for agent routing
Patient and screener survey-completion flows that trigger Clinical Writer processing MUST identify the target agent entry point using a stable `accessPointKey` rather than relying only on implicit prompt selection.

#### Scenario: Patient thank-you flow starts analysis
- **WHEN** the `survey-patient` thank-you flow requests a preliminary analysis
- **THEN** the request MUST identify the configured patient-facing access point for that handoff
- **AND** the backend MUST resolve the runtime prompt stack from that access-point configuration

#### Scenario: Screener-triggered report flow starts analysis
- **WHEN** a survey-completion flow in `survey-frontend` requests report generation
- **THEN** the request MUST identify the configured screener-facing access point for that workflow
- **AND** the runtime MUST not depend exclusively on a frontend-selected `promptKey`

