# patient-survey-flow Specification

## Purpose
TBD - created by archiving change patient-screen-flow. Update Purpose after archive.
## Requirements
### Requirement: Welcome Screen
The system MUST display a welcome screen with a call-to-action button to start the survey.

#### Scenario: User starts the survey
**Given** a user is on the welcome screen
**When** the user clicks the "Start Survey" button
**Then** the system MUST navigate to the survey screen.

### Requirement: Survey Screen
The system MUST present the survey instructions and survey questions to the user.

#### Scenario: User answers the survey
**Given** a user is on the survey screen
**When** the user answers all the questions
**Then** the system MUST navigate to the thank you screen.

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

### Requirement: Demographic Information Screen
The system MUST allow the user to enter their demographic information.

#### Scenario: User submits demographic information
**Given** a user is on the demographic information screen
**When** the user fills in the form and clicks "Submit"
**Then** the system MUST send the survey response to the AI agent with the user's personal data and navigate to the report page.

### Requirement: Report Page
The system MUST display the AI agent's response on a new report page.

#### Scenario: View report
**Given** a user is on the report page
**When** the user views the report
**Then** the report content MUST be selectable.

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

