# Patient Public Assessment Flows Specification

## Purpose
Consolidates the patient-facing screening flow (survey-patient), patient identification, and default screening configuration rules.

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
The page MUST include an "Converse com o especialista" section with an external Irlen Syndrome GPT link.

#### Scenario: User provides personal information
**Given** a user is on the thank you screen at Step 3  
**When** the user clicks the "Adicionar informações" button  
**Then** the system MUST navigate to the demographic information screen.

#### Scenario: User views the specialist link on thank-you page
- **WHEN** the user is on the thank-you page
- **THEN** a "Converse com o especialista" section MUST be visible with the Irlen Syndrome GPT link

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
The system MUST allow the user to enter additional demographic information. All fields on this page are optional. The page MUST NOT include patient identification fields (name, email, birth date) or a skip section. The medication field MUST support multi-select with autocomplete against the ANVISA reference list.

#### Scenario: User views demographics page
- **WHEN** the user navigates to the demographics page
- **THEN** the page MUST show only the "Dados complementares" section
- **AND** the page MUST NOT show the "Identificação" section
- **AND** the page MUST NOT show the "Adicionar informações é opcional" skip section

#### Scenario: User submits without filling optional fields
- **WHEN** the user taps the continue button without filling any optional fields
- **THEN** the system MUST proceed to the report page without validation errors

#### Scenario: User enters multiple medications
- **WHEN** the user selects "Sim" for psychiatric medication use
- **THEN** the form MUST display a multi-select autocomplete field
- **AND** the user MUST be able to add multiple medications from the reference list or manually
- **AND** each selected medication MUST appear as a removable chip

### Requirement: Report Page
The system MUST display the AI agent's response on a report page with back navigation to the thank-you page and a restart-survey action. The report generation MUST use the async task-based approach to avoid timeouts, and the page MUST offer email delivery of the report.

#### Scenario: View report with async processing
- **WHEN** a user arrives at the report page
- **THEN** the system MUST submit the response and start an async clinical writer task
- **AND** the system MUST poll for task completion instead of making a synchronous blocking call

#### Scenario: Report generation timeout handling
- **WHEN** the async task does not complete within the polling window
- **THEN** the system MUST show an explicit error message indicating the report is taking too long
- **AND** the system MUST offer a retry option
- **AND** the system MUST NOT freeze the UI with a synchronous blocking call

#### Scenario: Email delivery from report page
- **WHEN** the report is successfully loaded and the patient has an email
- **THEN** an "Enviar relatório por e-mail" button MUST be visible and enabled
- **AND** tapping it MUST send the report to the patient's email

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
The system MUST require acknowledgement of the `Aviso Inicial de Uso` before the public patient welcome screen becomes available. After acknowledgement, the system MUST navigate to the patient identification screen instead of directly to the welcome screen.

#### Scenario: Patient opens the Survey Patient app
- **WHEN** a user opens `survey-patient`
- **THEN** the application MUST show the initial-notice screen with the full notice content and acknowledgement checkbox
- **AND** the proceed button MUST remain disabled until the user checks the acknowledgement checkbox
- **AND** after acknowledgement the application MUST navigate to the patient identification screen

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

### Requirement: System MUST present a mandatory patient identification screen after the initial notice
After the patient accepts the initial notice, the system SHALL navigate to a `PatientIdentificationPage` that collects name, email, and birth date before any other screen.

#### Scenario: Patient completes identification
- **WHEN** the patient fills in name, email, and birth date and taps continue
- **THEN** the system MUST store the patient data in `AppSettings`
- **AND** the system MUST navigate to the welcome page

#### Scenario: Patient tries to skip identification
- **WHEN** the patient taps continue without filling required fields
- **THEN** the system MUST show validation errors for missing required fields
- **AND** the system MUST NOT navigate away from the identification screen

#### Scenario: Patient returns to identification screen on restart
- **WHEN** the user taps "Iniciar nova avaliação" and returns to the entry gate
- **THEN** after accepting the notice again, the identification screen MUST show empty fields (reset state)

### Requirement: Patient identification screen MUST use shared DsPatientIdentitySection
The identification page SHALL use the existing `DsPatientIdentitySection` widget from `packages/design_system_flutter` for name, email, and birth date fields.

#### Scenario: Identification screen renders correctly
- **WHEN** the identification screen is displayed
- **THEN** it MUST render name, email, and birth date fields via `DsPatientIdentitySection`
- **AND** email and birth date fields MUST be shown (`showEmail: true`, `showBirthDate: true`)

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

### Requirement: Radar visualization uses question labels and color
The thank-you radar MUST read from the question-level `label` metadata and render values on a fixed `0..3` range. The response-to-score mapping MUST be: `Quase nunca=0`, `Ocasionalmente=1`, `Frequentemente=2`, `Quase sempre=3`. When a question lacks a label, the radar SHALL fall back to `Q1`, `Q2`, etc., to avoid blank fields. Radar labels MUST include contrast-backed rendering (for example, darker label backgrounds with light text) so axis names remain readable.

#### Scenario: Radar renders mapped labeled data
- **WHEN** a thank-you screen renders survey responses with question labels
- **THEN** each radar axis MUST use the fixed `0..3` range with the defined option-to-score mapping
- **AND** the chart MUST color each spoke distinctly and surface the provided label near the axis or legend
- **AND** the chart SHALL not show raw question IDs such as `Q3` when labels are available

#### Scenario: Radar handles missing labels
- **WHEN** a question definition does not supply a label
- **THEN** the radar MUST render that axis as `Q<number>` (e.g., `Q4`) while still coloring the spoke
- **AND** the UI MAY prompt administrators to add labels in the builder for future deployments

#### Scenario: Radar labels remain readable on chart backgrounds
- **WHEN** radar labels are rendered over multicolor chart regions
- **THEN** label foreground and background treatment MUST provide high contrast readability
- **AND** the same readability treatment MUST be applied in both `survey-patient` and `survey-frontend`

### Requirement: “Iniciar nova avaliação” resets the session
The thank-you screen SHALL offer an “Iniciar nova avaliação” button that clears the patient app’s in-memory survey and response state, including any temporary tokens, and navigates back to the public welcome screen so a new respondent can start fresh without reloading the browser.

#### Scenario: Patient starts another assessment
- **WHEN** the user taps “Iniciar nova avaliação”
- **THEN** the app MUST clear stored answers, agent response state, and navigation history related to the completed survey
- **AND** it MUST navigate to the patient welcome page so a new token or link can be entered

### Requirement: Create System Screener
A default "System Screener" user MUST be created in the database.

#### Scenario: System startup
**Given** the `survey-backend` application starts
**When** the database is initialized
**Then** a "System Screener" user with the following data MUST be present in the `screeners` collection:
```json
{
   "cpf": "00000000000",
   "firstName": "LAPAN",
   "surname": "System Screener",
   "email": "lapan.hugodepaula@gmail.com",
   "password": "<randomly_generated_and_hashed>",
   "phone": "31984831284",
   "address": {
     "postalCode": "34000000",
     "street": "Rua da Paisagem",
     "number": "220",
     "complement": "",
     "neighborhood": "Vale do Sereno",
     "city": "Nova Lima",
     "state": "MG"
   },
   "professionalCouncil": {
     "type": "none",
     "registrationNumber": ""
   },
   "jobTitle": "",
   "degree": "",
   "darvCourseYear": null
}
```

### Requirement: Use System Screener in Patient App
The `survey-patient` app MUST use the "System Screener" as the default screener for all survey responses.

#### Scenario: Patient submits a survey
**Given** a patient is using the `survey-patient` app
**When** the patient submits a survey
**Then** the survey response sent to the backend MUST be associated with the "System Screener".

### Requirement: Backend MUST store a default screener questionnaire setting
The system SHALL persist a default questionnaire ID in a `system_settings` MongoDB collection with key `screener_default_questionnaire_id`.

#### Scenario: Default questionnaire is stored
- **WHEN** an admin sets a default questionnaire via survey-builder
- **THEN** the `system_settings` collection MUST contain a document with `key: "screener_default_questionnaire_id"`

### Requirement: survey-frontend MUST load default questionnaire at startup
The screener frontend SHALL load the default questionnaire from the backend when the app initializes and use it as the active questionnaire for new sessions.

#### Scenario: App loads with default questionnaire configured
-   **WHEN** the screener app starts
-   **AND** a default questionnaire is configured in the backend
-   **THEN** the app MUST load the default questionnaire
-   **AND** the app MUST use it as the active questionnaire without requiring manual selection

### Requirement: Backend MUST seed AI default model settings at startup
When the backend starts, it MUST ensure default AI model settings are present in `system_settings` using environment-derived values for Gemini and GLM models.

#### Scenario: Startup with missing model defaults
-   **WHEN** the backend starts and AI default model keys are missing in `system_settings`
-   **THEN** the backend MUST create the missing keys using `GEMINI_MODEL` and `GLM_MODEL` values

#### Scenario: Startup with existing model defaults
-   **WHEN** the backend starts and AI default model keys already exist in `system_settings`
-   **THEN** the backend MUST keep the existing persisted values unless an explicit refresh policy is configured

### Requirement: Backend MUST store a default screener questionnaire setting
The system SHALL persist a default questionnaire ID in a `system_settings` MongoDB collection with key `screener_default_questionnaire_id`. This setting determines the questionnaire loaded when a screener starts a new session.

#### Scenario: Default questionnaire is stored
- **WHEN** an admin sets a default questionnaire via survey-builder
- **THEN** the `system_settings` collection MUST contain a document with `key: "screener_default_questionnaire_id"` and `value` set to the questionnaire's MongoDB `_id`

#### Scenario: Default questionnaire is not set
- **WHEN** no default questionnaire has been configured
- **THEN** the system MUST return `null` for the setting
- **AND** the screener MUST be prompted to select a questionnaire manually

### Requirement: Backend MUST provide a screener settings API
The API SHALL expose `GET /v1/settings/screener` and `PUT /v1/settings/screener` for reading and updating screener configuration.

#### Scenario: Read screener settings
- **WHEN** a client calls `GET /v1/settings/screener`
- **THEN** the system MUST return the current screener settings including `default_questionnaire_id` and `default_questionnaire_name`

#### Scenario: Update screener settings
- **WHEN** an admin calls `PUT /v1/settings/screener` with a valid questionnaire ID
- **THEN** the system MUST validate the questionnaire exists
- **AND** the system MUST update the `screener_default_questionnaire_id` setting
- **AND** the system MUST return the updated settings

#### Scenario: Update with invalid questionnaire ID
- **WHEN** an admin calls `PUT /v1/settings/screener` with a questionnaire ID that does not exist
- **THEN** the system MUST return HTTP 422 with a validation error

### Requirement: survey-builder MUST provide a screener settings section
The survey-builder admin interface SHALL include a settings section where admins can configure the default screener questionnaire.

#### Scenario: Admin configures default questionnaire
- **WHEN** an admin navigates to the screener settings section in survey-builder
- **THEN** a dropdown of available questionnaires MUST be displayed
- **AND** the currently configured default questionnaire MUST be pre-selected
- **AND** the admin MUST be able to select a different questionnaire and save

#### Scenario: Admin saves screener settings
- **WHEN** the admin selects a questionnaire and taps save
- **THEN** the system MUST call `PUT /v1/settings/screener`
- **AND** a success feedback message MUST be displayed

### Requirement: survey-frontend MUST load default questionnaire at startup
The screener frontend SHALL load the default questionnaire from the backend when the app initializes and use it as the active questionnaire for new sessions.

#### Scenario: Default questionnaire falls back to CHYPS-V Br Q20
- **WHEN** the screener settings do not yet have an explicit default questionnaire
- **THEN** the system MUST resolve `CHYPS-V Br Q20` as the startup default questionnaire
- **AND** the resolved questionnaire MUST be persisted as `screener_default_questionnaire_id` for subsequent sessions

#### Scenario: App loads with default questionnaire configured
- **WHEN** the screener app starts
- **AND** a default questionnaire is configured in the backend
- **THEN** the app MUST load the default questionnaire
- **AND** the app MUST use it as the active questionnaire without requiring manual selection

#### Scenario: App loads without default questionnaire
- **WHEN** the screener app starts
- **AND** no default questionnaire is configured
- **THEN** the app MUST prompt the screener to select a questionnaire

### Requirement: Active session section MUST display the current questionnaire
The "Sessão profissional ativa" section on the settings or dashboard page SHALL display the name of the currently active questionnaire.

#### Scenario: Screener views active session info
- **WHEN** the screener is on the dashboard or settings page
- **THEN** the "Sessão profissional ativa" section MUST display the name of the active questionnaire
- **AND** the questionnaire name MUST match the default or manually selected questionnaire
