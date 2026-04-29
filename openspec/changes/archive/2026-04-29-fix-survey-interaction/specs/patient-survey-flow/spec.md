## MODIFIED Requirements

### Requirement: Thank You Screen
The system MUST display a thank you screen that follows a three-step handoff sequence: "Responses Registered", "Analysis in Progress", and "Report Ready".
- **Step 1 (Responses Registered)**: Acknowledge effort ("Obrigado por sua colaboração") and confirm data persistence before showing any protocol/reference ID.
- **Step 2 (Analysis in Progress)**: Show a colorful radar chart that uses question labels, and an **Avaliação preliminar** card with a loading state and stage label ("Análise preliminar em preparo").
- **Step 3 (Report Ready)**: Show the AI summary in a clinical container and options to provide personal information or generate the report.
A new "Iniciar nova avaliação" button SHALL reset the app state, clear the patient legal-notice acknowledgement for the next run, and return the user to the initial notice page.
The "Resumo das respostas" text list MUST NOT be displayed. The radar chart and legend chips MUST remain.

#### Scenario: User provides personal information
**Given** a user is on the thank you screen at Step 3
**When** the user clicks the "Adicionar informações" button
**Then** the system MUST navigate to the demographic information screen.

#### Scenario: Agent result appears in Avaliação preliminar
- **WHEN** the agent finishes processing the survey (Handoff Step 3)
- **THEN** the **Avaliação preliminar** card MUST show the agent text in a clinical container and keep the "Adicionar informações" action available
- **AND** there MUST NOT be a separate "Ver resultados" button on the thank you screen

#### Scenario: User restarts the flow
- **WHEN** the user taps "Iniciar nova avaliação"
- **THEN** the app MUST clear the previous response state, agent data, and patient legal-notice acknowledgement state
- **AND** it MUST navigate back to the patient initial-notice screen so the next assessment requires a fresh acknowledgement before the welcome screen

#### Scenario: User generates report from thank-you page
- **WHEN** the user taps "Gerar relatório" in the handoff fork
- **THEN** the system MUST navigate to the report page with the current survey, answers, and questions

#### Scenario: Answer summary is not displayed
- **WHEN** the user is on the thank-you page
- **THEN** the page MUST NOT render the "Resumo das respostas" text list with individual question-answer cards
- **AND** the radar chart and legend chips MUST remain visible

## MODIFIED Requirements

### Requirement: Report Page
The system MUST display the AI agent's response on a report page with back navigation to the thank-you page and a restart-survey action.

#### Scenario: View report
**Given** a user is on the report page
**When** the user views the report
**Then** the report content MUST be selectable.

#### Scenario: Back navigation to thank-you page
- **WHEN** a user taps the back button on the report page
- **THEN** the system MUST navigate to the thank-you page
- **AND** the back button label MUST read "Voltar"

#### Scenario: Restart survey from report page
- **WHEN** a user taps "Iniciar nova avaliação" on the report page
- **THEN** the system MUST reset the assessment flow and navigate to the initial notice screen

#### Scenario: Export report as text
**Given** a user is on the report page
**When** the user clicks the "Save as Text" button
**Then** the system MUST initiate a download of the report as a plain text file.

#### Scenario: Export report as PDF
**Given** a user is on the report page
**When** the user clicks the "Export as PDF" button
**Then** the system MUST initiate a process to save the report as a PDF file.
