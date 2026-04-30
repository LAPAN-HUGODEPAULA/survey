# generate-clinical-documents Specification

## Purpose
TBD - created by archiving change add-clinical-narrative-overview. Update Purpose after archive.
## Requirements
### Requirement: Document Generation
The system SHALL generate clinical documents from the conversation context and approved templates using an **asynchronous processing pattern**. The request SHALL return a job identifier immediately, allowing the user to monitor progress through standardized stages. Completion occurs only after the output passes the reflection-based safety review.

#### Scenario: User initiates document generation
- **WHEN** the clinician requests document generation
- **THEN** the system MUST return a `202 Accepted` status with a `jobId`
- **AND** the system SHALL begin processing in the background, transitioning through stages like `analyzing`, `drafting`, and `reviewing`.

#### Scenario: Generate visit document after successful review
- **WHEN** the background job reaches the `completed` state
- **THEN** the system provides the document filled with captured data, ensuring it has passed the reflection stage approval.

#### Scenario: School document requires rewrite after unsafe recommendation
- **GIVEN** the background job is in the `reviewing` stage
- **AND** the draft includes a medical prescription or invasive recommendation
- **WHEN** the reflection stage evaluates the draft
- **THEN** the system SHALL return the job to the `drafting` stage for correction rather than moving to `completed`.

### Requirement: Export and Print
The system SHALL allow PDF export and direct print option.

### Requirement: Report Page (survey-patient)
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

#### Scenario: Export PDF
- **WHEN** the clinician chooses export
- **THEN** the system generates a PDF of the document

