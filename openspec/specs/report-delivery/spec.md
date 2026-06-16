# report-delivery Specification

## Purpose
TBD - created by archiving change extract-response-report-delivery-services. Update Purpose after archive.
## Requirements
### Requirement: Response Submission Orchestration

Patient and survey response submissions SHALL be orchestrated by dedicated orchestrator services rather than route functions.

#### Scenario: Valid patient response submission

- GIVEN a valid patient response payload, WHEN submission runs, THEN the orchestrator MUST persist the response, resolve the access point selection, and defer the clinical AI agent processing.

#### Scenario: Valid survey response submission

- GIVEN a valid survey response payload, WHEN submission runs, THEN the orchestrator MUST persist the response, run the clinical AI agent inline, and build the report delivery payload.

### Requirement: Command-Based Report Delivery

Report email delivery SHALL execute via a Command DTO specifying the recipient, the resolved clinical text, and the attachment metadata.

#### Scenario: Unified ReportLab compilation

- GIVEN a report delivery command, WHEN compiling the attachment, THEN the service MUST generate a PDF utilizing ReportLab and MUST NOT import or utilize fpdf2.

#### Scenario: Path containment safety

- GIVEN a compiled PDF attachment, WHEN saving the temporary file for SMTP delivery, THEN the service MUST use the safe path boundary helper to enforce filesystem containment.

