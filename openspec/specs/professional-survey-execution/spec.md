# Professional Survey Execution & Patient Handoff Specification

## Purpose
Consolidates professional survey completion, access link generation, thank-you page actions, clinical summary visual divisions, and restart mechanics.

## Requirements
### Requirement: survey-frontend MUST provide a report page
The system SHALL display a report page (`report_page.dart`) that shows the AI-generated clinical report for the completed assessment. The report page MUST use the async task-based approach to avoid timeouts.

#### Scenario: Screener navigates to report page
- **WHEN** the screener taps "Gerar Relatório" on the thank-you page
- **THEN** the system MUST navigate to the report page
- **AND** the system MUST submit the response and start an async clinical writer task using the "Relatório clínico detalhado do paciente" access point
- **AND** the system MUST poll for task completion

#### Scenario: Report generation timeout handling
- **WHEN** the async task does not complete within the polling window
- **THEN** the system MUST show an explicit error message
- **AND** the system MUST offer a retry option
- **AND** the system MUST NOT freeze the UI with a synchronous blocking call

#### Scenario: Back navigation to thank-you page
- **WHEN** the screener taps the back button on the report page
- **THEN** the system MUST navigate to the thank-you page
- **AND** the back button label MUST read "Voltar"

### Requirement: Report page MUST offer email delivery of the report
The report page SHALL include an "Enviar relatório por e-mail" button that sends the generated report as a PDF to the patient's email.

#### Scenario: Screener sends report by email
- **WHEN** the screener taps "Enviar relatório por e-mail" on the report page
- **AND** the report has been successfully loaded
- **AND** the patient has an email address
- **THEN** the system MUST call the email delivery endpoint
- **AND** the system MUST show a success confirmation message

#### Scenario: Patient has no email
- **WHEN** the patient's email field is empty
- **THEN** the email button MUST be disabled
- **AND** a hint MUST explain that an email address is required

### Requirement: Report page MUST offer clinical document generation buttons
The report page SHALL include buttons for generating clinical referral letters. Each button triggers a separate access point that generates the corresponding document.

#### Scenario: Screener generates clinical referral letter
- **WHEN** the screener taps "Encaminhamento clínico"
- **THEN** the system MUST trigger the "Geração de carta de encaminhamento clínico" access point
- **AND** the system MUST display the generated document or offer download

#### Scenario: Screener generates school referral letter
- **WHEN** the screener taps "Encaminhamento escolar"
- **THEN** the system MUST trigger the "Geração de carta de encaminhamento escolar" access point
- **AND** the system MUST display the generated document or offer download

#### Scenario: Screener generates parent orientation letter
- **WHEN** the screener taps "Orientação aos pais"
- **THEN** the system MUST trigger the "Geração de carta de orientação aos pais" access point
- **AND** the system MUST display the generated document or offer download

#### Scenario: Clinical document generation in progress
- **WHEN** the screener taps any clinical document button
- **THEN** the button MUST show a loading state
- **AND** the button MUST be disabled until the document is generated

### Requirement: Screener thank-you page MUST display a preliminary AI assessment
The thank-you page in `survey-frontend` SHALL include a `DsSection` titled "Avaliação preliminar" that displays an AI-generated summary using the access point "Análise automática do questionário profissional" (`survey_frontend.thank_you.auto_analysis`). The access point MUST use the default survey prompt ("Triagem de pacientes") and `patient_condition_overview` persona.

#### Scenario: Preliminary assessment loads after survey completion
- **WHEN** the screener completes a survey and arrives at the thank-you page
- **THEN** the system MUST trigger the auto-analysis access point
- **AND** the "Avaliação preliminar" section MUST show a loading state with label "Análise preliminar em preparo"

#### Scenario: Preliminary assessment is displayed
- **WHEN** the AI agent finishes processing the survey
- **THEN** the "Avaliação preliminar" section MUST display the agent's summary text in a clinical content container
- **AND** the summary MUST use the `patient_condition_overview` persona output style

#### Scenario: Preliminary assessment fails
- **WHEN** the AI agent fails to produce a summary
- **THEN** the "Avaliação preliminar" section MUST show an error message
- **AND** the system MUST offer a retry option

### Requirement: Screener thank-you page MUST NOT display colored question labels in radar section
The "Radar das respostas" `DsSection` SHALL display the radar chart and legend chips without colored question labels.

#### Scenario: Radar section without colored labels
- **WHEN** the screener views the thank-you page
- **THEN** the "Radar das respostas" section MUST display the radar chart
- **AND** the section MUST NOT display colored question labels alongside the chart
- **AND** the legend chips MUST remain visible

### Requirement: Screener thank-you page MUST NOT display answer summary
The "Resumo das respostas" section MUST be completely removed from the thank-you page in `survey-frontend`.

#### Scenario: Answer summary is not displayed
- **WHEN** the screener views the thank-you page
- **THEN** the page MUST NOT render the "Resumo das respostas" section
- **AND** the page MUST NOT render individual question-answer cards
- **AND** the radar chart and preliminary assessment MUST remain visible

### Requirement: Screener pages MUST display centered titles in AppBar
Each screener page MUST display a centered title in the AppBar.

#### Scenario: All assessment flow pages use centered AppBar titles
- **WHEN** the screener navigates across demographics, clinical context, instructions, questionnaire, thank-you, and report pages
- **THEN** each page AppBar title MUST be centered
- **AND** no page in this flow may use a left-aligned title style

#### Scenario: Demographics page title
- **WHEN** the screener is on the demographics page
- **THEN** the AppBar title MUST read "Avaliação do paciente" and MUST be centered

#### Scenario: Instructions page title
- **WHEN** the screener is on the instructions page
- **THEN** the AppBar title MUST be centered

#### Scenario: Thank-you page title
- **WHEN** the screener is on the thank-you page
- **THEN** the AppBar title MUST be centered

### Requirement: Thank-you page MUST NOT display text-based answer summary
The thank-you page SHALL remove the "Resumo das respostas" section that renders individual question-answer pairs in `DsFocusFrame` cards. The radar chart and legend chips MUST remain.

#### Scenario: User views thank-you page after survey completion
- **WHEN** a user completes the survey and arrives at the thank-you page
- **THEN** the page MUST display the radar chart and legend chips
- **AND** the page MUST NOT display the "Resumo das respostas" text list with individual answer cards

### Requirement: Thank-you page MUST offer a "Gerar relatório" action
The `DsHandoffFork` on the thank-you page SHALL include a second action titled "Gerar relatório" alongside the existing "Adicionar informações" action. The "Gerar relatório" action MUST navigate to the report page.

#### Scenario: User generates report from thank-you page
- **WHEN** a user is on the thank-you page and taps "Gerar relatório"
- **THEN** the system MUST navigate to the report page with the current survey, answers, and questions
- **AND** both "Adicionar informações" and "Gerar relatório" MUST be visible simultaneously in the handoff fork

### Requirement: Thank-you page MUST offer a "Gerar Relatório" action in survey-frontend
The screener `thank_you_page.dart` SHALL include a secondary action titled "Gerar Relatório" that mirrors the behavior and visual hierarchy used in `survey-patient`.

#### Scenario: Screener sees report generation action
- **WHEN** the screener arrives at the thank-you page after completing a questionnaire
- **THEN** both actions "Adicionar informações" and "Gerar Relatório" MUST be visible
- **AND** the "Gerar Relatório" action MUST use the same interaction pattern as `survey-patient`

#### Scenario: Screener starts report flow
- **WHEN** the screener taps "Gerar Relatório"
- **THEN** the app MUST navigate to `report_page.dart`
- **AND** the report flow MUST carry the completed survey context needed for document generation

### Requirement: Screener thank-you page MUST display a preliminary AI assessment
The thank-you page in `survey-frontend` SHALL include a `DsSection` titled "Avaliação preliminar" that displays an AI-generated summary using the access point "Análise automática do questionário profissional" (`survey_frontend.thank_you.auto_analysis`).

#### Scenario: Preliminary assessment loads after survey completion
- **WHEN** the screener completes a survey and arrives at the thank-you page
- **THEN** the system MUST trigger the auto-analysis access point
- **AND** the "Avaliação preliminar" section MUST show a loading state with label "Análise preliminar em preparo"

#### Scenario: Preliminary assessment is displayed
- **WHEN** the AI agent finishes processing the survey
- **THEN** the "Avaliação preliminar" section MUST display the agent's summary text in a clinical content container

### Requirement: Screener thank-you page MUST NOT display colored question labels in radar section
The "Radar das respostas" `DsSection` SHALL display the radar chart and legend chips without colored question labels.

#### Scenario: User views radar without colored labels
- **WHEN** the user completes the survey in survey-frontend
- **THEN** the radar chart MUST be visible
- **AND** question labels MUST NOT be displayed alongside the chart

### Requirement: Screener pages MUST display centered titles in AppBar
Each screener page MUST display a centered title in the AppBar.

#### Scenario: User navigates screener flow
- **WHEN** the user moves between demographics and report pages
- **THEN** each page AppBar MUST show a centered title

### Requirement: Report page MUST provide back navigation to thank-you page
`ReportPage` SHALL include a back button that navigates to the thank-you page (`ThankYouPage`). The `DsScaffold.onBack` MUST pop to the thank-you page route, and `backLabel` MUST read "Voltar".

#### Scenario: User taps back on report page
- **WHEN** a user is on the report page and taps the back button
- **THEN** the system MUST navigate to the thank-you page
- **AND** the back button label MUST read "Voltar"

### Requirement: Report page MUST provide a restart-survey action
`ReportPage` SHALL display a full-width "Iniciar nova avaliação" button at the bottom of the page. This button MUST accept an `onRestartSurvey` callback that resets the assessment flow and navigates to the entry gate, identical to the behavior on `thank_you_page.dart`.

#### Scenario: User restarts survey from report page
- **WHEN** a user taps "Iniciar nova avaliação" on the report page
- **THEN** the system MUST clear the previous response state, agent data, and patient legal-notice acknowledgement
- **AND** the system MUST navigate to the initial notice screen
- **AND** the button styling MUST match the equivalent button on `thank_you_page.dart`

### Requirement: Generate Screener Questionnaire Access Link
The system MUST allow an operator to generate a reusable opaque access link for a selected screener and selected questionnaire in `survey-frontend`.

#### Scenario: Generate a link after choosing the screener and questionnaire
**Given** an operator has a screener available for use
**And** a questionnaire is selected in `survey-frontend`
**When** the operator requests a questionnaire link
**Then** the system MUST create an opaque reusable link bound to that screener and questionnaire
**And** the system MUST present the generated URL in a copyable format
**And** the system MUST offer exports as plain text and QR code in `PNG` format.

#### Scenario: Support more than one prepared link per screener
**Given** a screener already has a generated access link for one questionnaire
**When** an operator generates a link for the same screener with another questionnaire
**Then** the system MUST allow the new link to be created
**And** each link MUST resolve to its own screener-questionnaire pair.

### Requirement: Launch the App in Locked Assessment Mode
The system MUST open `survey-frontend` in a locked assessment mode when a valid access link is used.

#### Scenario: Open a valid access link
**Given** a reusable access link exists for a screener and questionnaire
**When** a user opens the link
**Then** the application MUST resolve the link before starting the assessment flow
**And** the screener and questionnaire MUST be preselected automatically
**And** the user MUST be taken directly into the assessment flow without needing manual setup
**And** the setup controls for changing the screener or questionnaire MUST be hidden or disabled.

#### Scenario: Preserve locked setup during the session
**Given** a user entered `survey-frontend` through a valid access link
**When** the user navigates through the assessment flow
**Then** the linked screener and questionnaire MUST remain fixed for that session
**And** the interface MUST clearly explain that the session was opened from a prepared link.

### Requirement: Provide Accessible Link Sharing Outputs
The system MUST provide low-friction sharing outputs for non-technical users when a prepared access link is generated.

#### Scenario: Share the generated link
**Given** an access link has been generated successfully
**When** the operator views the generated-link state
**Then** the system MUST provide clear actions to copy the URL, save the URL as text, and save the QR code as `PNG`
**And** each action MUST provide accessible feedback confirming success or failure
**And** the labels and instructions MUST use clear non-technical pt-BR language.

### Requirement: Show an Informational Unavailable Page
The system MUST show an informational unavailable page when a prepared access link can no longer be used.

#### Scenario: Linked screener is no longer available
**Given** an access link points to a screener that is no longer available
**When** a user opens the link
**Then** the application MUST show an informational page instead of a technical error page
**And** the page MUST explain that the screener or questionnaire is no longer available
**And** the page MUST instruct the user to contact the current screener or `lapan.hugodepaula@gmail.com`.

#### Scenario: Linked questionnaire is no longer available
**Given** an access link points to a questionnaire that is no longer available
**When** a user opens the link
**Then** the application MUST show the same informational unavailable experience
**And** the page MUST avoid technical error terminology
**And** the page MUST remain accessible to keyboard and assistive-technology users.

### Requirement: Three-Step Survey Completion Handoff
The system SHALL implement a visually distinct three-step handoff sequence upon survey submission to guide the user from completion to results.

#### Scenario: Sequence of stages
- **WHEN** the user submits a survey
- **THEN** the system SHALL display the sequence: "Responses Registered" (Respostas registradas), then "Analysis in Progress" (Análise preliminar em preparo), and finally "Report Ready" (Relatório disponível)
- **AND** EACH stage MUST be clearly labeled in Brazilian Portuguese (pt-BR).

### Requirement: Visual Separation of System and Clinical Content
The system SHALL use distinct visual containers to separate system status messages (e.g., progress, saving) from clinical feedback or report content.

#### Scenario: Separation on summary page
- **WHEN** the user is on the assessment summary page
- **THEN** system status messages (like "Relatório sendo gerado...") MUST use a functional/status container
- **AND** clinical results or patient notes MUST use a content/clinical container (e.g., card with different background or border).

### Requirement: Delayed Reference ID Presentation
The system SHALL only display the assessment reference/protocol ID after providing a plain-language explanation of its purpose.

#### Scenario: Reference ID with context
- **WHEN** the survey is successfully saved and the ID is generated
- **THEN** the system SHALL first display: "Sua avaliação foi salva. Este código identifica o atendimento para futuras consultas:"
- **AND** then display the reference ID.

### Requirement: Empathetic Effort Acknowledgment
The system SHALL include microcopy that acknowledges the user's effort and contribution upon survey completion.

#### Scenario: Acknowledgment in patient flow
- **WHEN** the patient completes the screening
- **THEN** the system SHALL display: "Obrigado por sua colaboração. Suas respostas ajudam a construir um olhar mais cuidadoso para sua saúde."

### Requirement: Optional Enrichment Guidance
The system SHALL provide clear guidance for optional demographic or clinical enrichment steps, explaining the benefits of providing more data.

#### Scenario: Optional demographics fork
- **WHEN** the basic screening is complete and optional demographics are available
- **THEN** the system SHALL explain: "Estas informações opcionais ajudam em pesquisas estatísticas, mas você pode pular esta etapa se preferir."

### Requirement: Survey completion handoff MUST use explicit access-point keys for agent routing
Patient and screener survey-completion flows that trigger Clinical Writer processing MUST identify the target agent entry point using a stable `accessPointKey` rather than relying only on implicit prompt selection.

#### Scenario: Patient thank-you flow starts analysis
- **WHEN** the `survey-patient` thank-you flow requests a preliminary analysis
- **THEN** the request MUST identify the configured patient-facing access point for that handoff
- **AND** the backend MUST resolve the runtime prompt stack from that access-point configuration

#### Scenario: Screener-triggered report flow starts analysis
- **WHEN** a survey-completion flow in `survey-frontend` requests report generation
- **THEN** the request MUST identify the configured screener-facing access point for that workflow
- **AND** the runtime MUST not depend exclusively on a frontend-selected `promptKey`

### Requirement: Associate Survey with Screener
The system MUST associate a survey response with the screener who administered it.

#### Scenario: Create a survey response with a logged-in screener
**Given** a screener is logged in
**When** the screener creates a new survey response
**Then** the survey response MUST be associated with the logged-in screener's ID.

#### Scenario: Create a survey response through a prepared access link
**Given** a user opened `survey-frontend` through a valid prepared access link
**When** the user submits the survey response
**Then** the survey response MUST be associated with the screener linked to that access link.

#### Scenario: Create a survey response without a logged-in screener (patient app)
**Given** a survey response is created from the `survey-patient` app
**When** the survey response is saved
**Then** the survey response MUST be associated with the "System Screener" user.

### Requirement: Thank-you page MUST include an external specialist link section
The thank-you page SHALL display a `DsSection` titled "Converse com o especialista" with a link to an external Irlen Syndrome GPT.

#### Scenario: User views the specialist link section
- **WHEN** the user is on the thank-you page
- **THEN** the page MUST display a section titled "Converse com o especialista"
- **AND** the section MUST include explanatory text stating this GPT is an external LAPAN project focused on visual distress and learning
- **AND** the section MUST mention it can provide useful tips for visual sensitivity problems
- **AND** the section MUST include a button or link that opens `https://chatgpt.com/g/g-699b668db91c8191877e65ba10726cd2-irlen-syndrome-for-teachers-and-educators` in a new browser tab

#### Scenario: User taps the external link
- **WHEN** the user taps the GPT link button
- **THEN** the URL MUST open in a new browser tab or window
- **AND** the current survey app MUST remain open
