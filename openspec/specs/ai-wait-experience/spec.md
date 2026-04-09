# ai-wait-experience Specification

## Purpose
TBD - created by archiving change cr-ux-005-ai-waiting-states. Update Purpose after archive.
## Requirements
### Requirement: Stage Display via Stepper
Every flow involving long-duration AI processing (more than 3 seconds) SHALL display the current processing stage using a vertical `DsStepper` component (per CR-UX-004), mapping the real stages of the AI graph.

#### Scenario: View stages in questionnaire
- **WHEN** the user finalizes the questionnaire and the AI starts generating the report
- **THEN** the system SHALL sequentially show the stages in the stepper: "Organizando dados", "Analisando sinais", "Escrevendo rascunho", "Revisando conteúdo"
- **AND** SHALL use the Brazilian Portuguese (pt-BR) language.

### Requirement: Reassurance and Value Microcopy
Each AI waiting stage SHALL include contextualized reassurance microcopy using the `DsFeedback` component (per CR-UX-001) to explain the value of the current processing.

#### Scenario: Reassurance during clinical analysis
- **WHEN** the system is in the "Analisando sinais clínicos" stage
- **THEN** the system SHALL display: "Estamos analisando os sinais principais do caso para uma leitura inicial mais cuidadosa."
- **AND** the message SHALL have `info` or `processing` severity.

### Requirement: Form Submission Cycle Integration
The AI waiting state SHALL immediately succeed the form `submitted` state (per CR-UX-003), ensuring there is no visual vacuum between data submission and the start of processing.

#### Scenario: Transition from questionnaire to analysis
- **WHEN** the backend confirms receipt (`submitted`)
- **THEN** the UI SHALL transition smoothly to the `DsAIProgressIndicator`
- **AND** SHALL provide "Wayfinding" guidance (CR-UX-004) if the user can continue navigating.

### Requirement: Standardized AI Error Management
AI processing failures SHALL be communicated via `DsFeedback` (CR-UX-001), distinguishing between recoverable errors (automatic retry) and fatal errors.

#### Scenario: Timeout failure in analysis
- **WHEN** the analysis exceeds the allowed timeout
- **THEN** the system SHALL display feedback with `warning` severity
- **AND** SHALL offer the option to "Tentar Novamente" manually.

