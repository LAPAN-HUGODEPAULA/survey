## ADDED Requirements

### Requirement: Initial Notice Gate
The system MUST require acknowledgement of the `Aviso Inicial de Uso` before the public patient welcome screen becomes available.

#### Scenario: Patient opens the Survey Patient app
- **WHEN** a user opens `survey-patient`
- **THEN** the application MUST show the initial-notice screen with the full notice content and acknowledgement checkbox
- **AND** the proceed button MUST remain disabled until the user checks the acknowledgement checkbox
- **AND** after acknowledgement the application MUST navigate to the patient welcome screen

## MODIFIED Requirements

### Requirement: Thank You Screen
The system MUST display a thank you screen with a summary of the user's answers, a colorful radar chart that uses question labels, an **Avaliação preliminar** card that surfaces the agent response inline (with loading and error states), and an option to provide personal information. A new “Iniciar nova avaliação” button SHALL reset the app state, clear the patient legal-notice acknowledgement for the next run, and return the user to the initial notice page without requiring a browser reload.

#### Scenario: User provides personal information
**Given** a user is on the thank you screen  
**When** the user clicks the "Adicionar informações" button  
**Then** the system MUST navigate to the demographic information screen.

#### Scenario: Agent result appears in Avaliação preliminar
- **WHEN** the agent finishes processing the survey
- **THEN** the **Avaliação preliminar** card MUST show the agent text and keep the “Adicionar informações” action available
- **AND** there MUST NOT be a separate “Ver resultados” button on the thank you screen

#### Scenario: User restarts the flow
- **WHEN** the user taps “Iniciar nova avaliação”
- **THEN** the app MUST clear the previous response state, agent data, and patient legal-notice acknowledgement state
- **AND** it MUST navigate back to the patient initial-notice screen so the next assessment requires a fresh acknowledgement before the welcome screen
