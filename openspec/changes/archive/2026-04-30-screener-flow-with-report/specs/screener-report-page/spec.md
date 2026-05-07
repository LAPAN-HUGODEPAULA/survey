## ADDED Requirements

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
