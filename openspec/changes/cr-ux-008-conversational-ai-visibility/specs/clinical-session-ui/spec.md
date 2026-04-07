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

### Requirement: Painel de Insights da Sessão
O sistema DEVE exibir um painel lateral ou seção dedicada para exibir insights gerados por IA em tempo real, utilizando cartões padronizados.

#### Scenario: Visualizar novo insight durante a sessão
- **WHEN** a IA gera uma nova hipótese ou sugestão
- **THEN** o sistema adiciona um cartão ao painel de insights com o ícone e severidade adequados.
