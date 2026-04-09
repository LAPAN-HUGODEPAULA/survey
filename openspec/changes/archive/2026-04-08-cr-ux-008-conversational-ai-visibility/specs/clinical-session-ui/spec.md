## MODIFIED Requirements

### Requirement: Clinical Session Creation
The system SHALL allow starting a new session with or without a patient link.

#### Scenario: Start session without patient
- **WHEN** the clinician chooses to start without a patient
- **THEN** the session is created without identifiable data

#### Scenario: Start session with patient
- **WHEN** the clinician selects a patient
- **THEN** the session is created with loaded context

### Requirement: Session Header
The system SHALL display a header with humanized session status, duration, and primary actions.

#### Scenario: Active session
- **WHEN** the session is active
- **THEN** the header shows "Sessão Ativa", duration, and available actions

#### Scenario: Finished session
- **WHEN** the session is completed
- **THEN** the header shows "Sessão Concluída" and input is disabled

## ADDED Requirements

### Requirement: Session Insight Panel
The system SHALL display a side panel or dedicated section to show AI-generated insights in real-time, using standardized cards.

#### Scenario: View new insight during session
- **WHEN** the AI generates a new hypothesis or suggestion
- **THEN** the system adds a card to the insight panel with the appropriate icon and severity.
