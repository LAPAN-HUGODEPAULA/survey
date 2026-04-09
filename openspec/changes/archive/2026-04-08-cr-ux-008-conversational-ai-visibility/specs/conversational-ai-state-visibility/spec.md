## ADDED Requirements

### Requirement: Unified Assistant Status Area
The system SHALL expose a single status area ("Status do Assistente") that consolidates all AI processing states (voice, transcription, analysis).

#### Scenario: View status during conversation
- **WHEN** the AI is processing the clinician's voice input
- **THEN** the system displays a unified status indicator with the current phase and a discrete activity animation
- **AND** uses Brazilian Portuguese (pt-BR)

### Requirement: Humanization of Technical Phases
The system SHALL translate internal technical phases (`analysisPhase`) into humanized clinical terms in pt-BR.

#### Scenario: Translation of internal phases
- **WHEN** the internal phase is `intake` -> **THEN** the system displays "Organizando a anamnese"
- **WHEN** the internal phase is `assessment` -> **THEN** the system displays "Analisando sinais clínicos"
- **WHEN** the internal phase is `plan` -> **THEN** the system displays "Estruturando o plano"
- **WHEN** the internal phase is `wrap_up` -> **THEN** the system displays "Preparando o encerramento"

### Requirement: User Control over AI Processing
The system SHALL provide visible controls so that the user can intervene in AI processing when there are delays or failures.

#### Scenario: Cancel analysis in progress
- **WHEN** an AI analysis is being generated
- **THEN** the system displays a "Cancelar" or "Continuar manualmente" button visible in the status area
