## MODIFIED Requirements

### Requirement: Thank You Screen
The system MUST display a thank you screen that follows a three-step handoff sequence: "Responses Registered", "Analysis in Progress", and "Report Ready". 
- **Step 1 (Responses Registered)**: Acknowledge effort ("Obrigado por sua colaboração") and confirm data persistence before showing any protocol/reference ID.
- **Step 2 (Analysis in Progress)**: Show a colorful radar chart that uses question labels, and an **Avaliação preliminar** card with a loading state and stage label ("Análise preliminar em preparo"). 
- **Step 3 (Report Ready)**: Show the AI summary in a clinical content container and an option to provide personal information. 
A new “Iniciar nova avaliação” button SHALL reset the app state, clear the patient legal-notice acknowledgement for the next run, and return the user to the initial notice page.

#### Scenario: User provides personal information
**Given** a user is on the thank you screen at Step 3  
**When** the user clicks the "Adicionar informações" button  
**Then** the system MUST navigate to the demographic information screen.

#### Scenario: Agent result appears in Avaliação preliminar
- **WHEN** the agent finishes processing the survey (Handoff Step 3)
- **THEN** the **Avaliação preliminar** card MUST show the agent text in a clinical container and keep the “Adicionar informações” action available
- **AND** there MUST NOT be a separate “Ver resultados” button on the thank you screen

#### Scenario: User restarts the flow
- **WHEN** the user taps “Iniciar nova avaliação”
- **THEN** the app MUST clear the previous response state, agent data, and patient legal-notice acknowledgement state
- **AND** it MUST navigate back to the patient initial-notice screen so the next assessment requires a fresh acknowledgement before the welcome screen

### Requirement: Demographic Information Screen
The system MUST allow the user to enter their demographic information. If this step is optional, the system MUST explain the benefits of providing data and allow skipping.

#### Scenario: User submits demographic information
**Given** a user is on the demographic information screen
**When** the user fills in the form and clicks "Submit"
**Then** the system MUST send the survey response to the AI agent with the user's personal data and navigate to the report page.

#### Scenario: Optional demographics explanation
**Given** a user is on the demographic information screen
**When** the screen is optional
**Then** the system MUST display: "Estas informações opcionais ajudam em pesquisas estatísticas, mas você pode pular esta etapa se preferir."
