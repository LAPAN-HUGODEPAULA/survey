## MODIFIED Requirements

### Requirement: Report Page
The system MUST display the AI agent's response on a report page. The report generation MUST use the async task-based approach to avoid timeouts, and the page MUST offer email delivery of the report.

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
