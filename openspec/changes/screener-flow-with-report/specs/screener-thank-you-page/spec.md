## ADDED Requirements

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
