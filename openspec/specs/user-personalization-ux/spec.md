# user-personalization-ux Specification

## Purpose
TBD - created by archiving change cr-ux-009-emotional-design-layer. Update Purpose after archive.
## Requirements
### Requirement: Personalized Greetings and Feedback
The system SHALL use basic user data (e.g., name, clinical name) to create more empathetic and familiar greetings and feedbacks, provided it does not compromise privacy.

#### Scenario: Patient Greeting
- **WHEN** the patient provides their name in demographics
- **THEN** the system uses their name in progress and waiting messages (e.g., "Olá, [Nome]. Estamos preparando seu relatório")

#### Scenario: Professional Greeting
- **WHEN** the professional accesses the dashboard
- **THEN** the system displays a contextual and professional greeting (e.g., "Bom dia, Dr(a). [Nome]. Você tem 3 atendimentos pendentes")

### Requirement: Waiting State Personalization
Waiting messages SHALL be personalized for the current task context to reduce anxiety.

#### Scenario: Waiting for Narrative AI
- **WHEN** the AI is generating a clinical document
- **THEN** the system displays: "Olá, [Screener]. Estamos analisando os sinais principais do caso para gerar o rascunho. Isso levará apenas alguns instantes"

