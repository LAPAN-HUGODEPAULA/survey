## MODIFIED Requirements

### Requirement: Avaliação preliminar card surfaces agent findings inline
The thank-you screen SHALL render a card titled **Avaliação preliminar** that displays the latest agent response directly. It SHALL follow a three-step handoff model:
1. **Respostas registradas**: Confirming data persistence.
2. **Análise em preparo**: Showing a loading indicator while the agent reply is pending.
3. **Relatório disponível**: Displaying the agent findings.
The card SHALL visually separate system status messages (e.g., "Processando...") from the clinical content once available. It SHALL include the “Adicionar informações” action that navigates to the demographic/report workflow.

#### Scenario: Agent result is available (Handoff Step 3)
- **WHEN** the thank-you screen reaches the final handoff stage and the agent response finishes successfully
- **THEN** the **Avaliação preliminar** card MUST display the agent text (e.g., a summary paragraph, insights, or flags) in a distinct clinical content container
- **AND** the “Adicionar informações” button MUST remain visible below the agent text

#### Scenario: Agent result is still running (Handoff Step 2)
- **WHEN** the thank-you screen loads and the responses are already registered but the agent response is pending
- **THEN** the **Avaliação preliminar** card MUST show a spinner and the stage label "Análise preliminar em preparo" in a functional status container
- **AND** it MUST prevent the agent text from being shown until the request completes

#### Scenario: Agent request fails
- **WHEN** the agent request returns an error or times out during Step 2
- **THEN** the **Avaliação preliminar** card MUST show an inline error banner (e.g., “Não foi possível obter a avaliação preliminar.”)
- **AND** the “Adicionar informações” action MUST still be available so the patient can continue
