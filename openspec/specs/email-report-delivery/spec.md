# email-report-delivery Specification

## Purpose
Backend and frontend support for sending PDF reports via email to patients.

## Requirements
### Requirement: Report page MUST offer email delivery of the report
The report page SHALL include an "Enviar relatório por e-mail" button that sends the generated report to the patient's email address.

#### Scenario: User sends report by email
- **WHEN** the user taps "Enviar relatório por e-mail" on the report page
- **AND** the report has been successfully loaded
- **AND** the patient has an email address
- **THEN** the system MUST call the email delivery endpoint
- **AND** the system MUST show a success confirmation toast

#### Scenario: Patient has no email
- **WHEN** the patient's email field is empty
- **THEN** the email button MUST be disabled
- **AND** a tooltip or hint MUST explain that an email address is required

#### Scenario: Email delivery fails
- **WHEN** the email delivery endpoint returns an error
- **THEN** the system MUST show an error message indicating the delivery failed
- **AND** the user MUST be able to retry

### Requirement: Backend MUST provide a report email endpoint
The API SHALL expose `POST /v1/patient_responses/{response_id}/send_report_email` that sends the generated report as a PDF attachment to the patient's email.

#### Scenario: Backend sends report email successfully
- **WHEN** the endpoint is called with a valid response ID that has an agent response with report data
- **AND** the patient has an email address
- **THEN** the system MUST generate a PDF from the report text
- **AND** the system MUST send an email with the PDF attached to the patient's email
- **AND** a copy MUST be sent to the configured LAPAN email

#### Scenario: Response not found
- **WHEN** the endpoint is called with a non-existent response ID
- **THEN** the system MUST return HTTP 404

#### Scenario: No report data available
- **WHEN** the response exists but has no agent response or report
- **THEN** the system MUST return HTTP 422 with a descriptive message
