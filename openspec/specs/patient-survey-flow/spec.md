# patient-survey-flow Specification

## Purpose
TBD - created by archiving change patient-screen-flow. Update Purpose after archive.
## Requirements
### Requirement: Welcome Screen
The system MUST display a welcome screen with a call-to-action button to start the survey and MUST remove motivational subtitle copy that reduces readability focus for this flow.

#### Scenario: User starts the survey
- **Given** a user is on the welcome screen
- **When** the user clicks the "Start Survey" button
- **Then** the system MUST navigate to the survey screen.

#### Scenario: Welcome subtitle text is removed
- **WHEN** the welcome screen is rendered in `survey-patient`
- **THEN** the text `"Olá! Estamos com você em cada etapa."` MUST NOT be displayed
- **AND** the primary welcome heading and start action MUST remain visible

### Requirement: Survey Screen
The system MUST present the survey instructions and survey questions to the user and MUST keep respondent content reachable on low-resolution devices.

#### Scenario: User answers the survey
- **Given** a user is on the survey screen
- **When** the user answers all the questions
- **Then** the system MUST navigate to the thank you screen.

#### Scenario: User accesses full survey content on low-resolution devices
- **WHEN** the survey screen content exceeds the viewport height
- **THEN** the screen MUST allow vertical scrolling of the respondent section content
- **AND** no required instruction or question control may become unreachable due to fixed-height clipping

### Requirement: Thank You Screen
The system MUST display a thank you screen that follows a three-step handoff sequence: "Responses Registered", "Analysis in Progress", and "Report Ready". 
- **Step 1 (Responses Registered)**: Acknowledge effort ("Obrigado por sua colaboração") and confirm data persistence before showing any protocol/reference ID.
- **Step 2 (Analysis in Progress)**: Show a colorful radar chart that uses question labels, and an **Avaliação preliminar** card with a loading state and stage label ("Análise preliminar em preparo"). 
- **Step 3 (Report Ready)**: Show the AI summary in a clinical content container and options to provide personal information or generate the report. 
A new “Iniciar nova avaliação” button SHALL reset the app state, clear the patient legal-notice acknowledgement for the next run, and return the user to the initial notice page.
The "Resumo das respostas" text list MUST NOT be displayed. The radar chart and legend chips MUST remain.

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

#### Scenario: User generates report from thank-you page
- **WHEN** the user taps "Gerar relatório" in the handoff fork
- **THEN** the system MUST navigate to the report page with the current survey, answers, and questions

#### Scenario: Answer summary is not displayed
- **WHEN** the user is on the thank-you page
- **THEN** the page MUST NOT render the "Resumo das respostas" text list with individual question-answer cards
- **AND** the radar chart and legend chips MUST remain visible

### Requirement: Demographic Information Screen
The system MUST allow the user to enter their demographic information. If this step is optional, the system MUST explain the benefits of providing data and allow skipping. The medication field MUST support multi-select with autocomplete against the ANVISA reference list.

#### Scenario: User submits demographic information
**Given** a user is on the demographic information screen
**When** the user fills in the form and clicks "Submit"
**Then** the system MUST send the survey response to the AI agent with the user's personal data and navigate to the report page.
**And** the medication field MUST contain a list of selected medication names.

#### Scenario: Optional demographics explanation
**Given** a user is on the demographic information screen
**When** the screen is optional
**Then** the system MUST display: "Estas informações opcionais ajudam em pesquisas estatísticas, mas você pode pular esta etapa se preferir."

#### Scenario: User enters multiple medications
- **WHEN** the user selects "Sim" for psychiatric medication use
- **THEN** the form MUST display a multi-select autocomplete field
- **AND** the user MUST be able to add multiple medications from the reference list or manually
- **AND** each selected medication MUST appear as a removable chip

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

### Requirement: Survey Response Submission
The backend MUST accept survey responses with or without patient data.

#### Scenario: Submit survey with patient data
**Given** a survey response contains patient data
**When** the response is submitted to the `create_survey_response` endpoint
**Then** the system MUST accept the response and store it.

#### Scenario: Submit survey without patient data
**Given** a survey response does not contain patient data
**When** the response is submitted to the `create_survey_response` endpoint
**Then** the system MUST accept the response and store it with a null value for patient data.

### Requirement: Initial Notice Gate
The system MUST require acknowledgement of the `Aviso Inicial de Uso` before the public patient welcome screen becomes available.

#### Scenario: Patient opens the Survey Patient app
- **WHEN** a user opens `survey-patient`
- **THEN** the application MUST show the initial-notice screen with the full notice content and acknowledgement checkbox
- **AND** the proceed button MUST remain disabled until the user checks the acknowledgement checkbox
- **AND** after acknowledgement the application MUST navigate to the patient welcome screen

### Requirement: Patient survey flow MUST use structured feedback messaging
The `survey-patient` flow MUST present important informational, success, warning, and error states through structured feedback containers that match the user's context in the journey.

#### Scenario: A patient triggers a demographics validation problem
- **WHEN** the patient attempts to continue with missing required information in the demographics flow
- **THEN** the application MUST present the validation state near the affected inputs or section
- **AND** the patient MUST receive clear guidance on what needs attention without relying only on a transient snackbar

#### Scenario: The patient sees survey-processing or report-state feedback
- **WHEN** the thank-you or report flow needs to communicate submission, fallback, warning, or report-preparation state
- **THEN** the application MUST render those updates through structured status surfaces with explicit severity and readable text
- **AND** the flow MUST distinguish informational progress from warnings and errors

