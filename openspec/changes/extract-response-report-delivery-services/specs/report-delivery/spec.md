# Delta for report-delivery

## ADDED Requirements

### Requirement: Response Creation Use Case

Patient and survey response creation SHALL be orchestrated by service-layer use cases rather than large route functions.

#### Scenario: Valid response creation

- GIVEN a valid response payload and authorized principal or valid access link, WHEN the route receives the request, THEN the use case MUST persist the response and return a typed API result.

#### Scenario: Persistence failure

- GIVEN repository failure, WHEN response creation runs, THEN the route MUST return a controlled error without leaking raw patient payloads.

### Requirement: Report Delivery Service

Report email delivery SHALL use a shared service for text resolution, attachment generation, and email sending.

#### Scenario: Structured report formatting

- GIVEN structured report output from Clinical Writer, WHEN report delivery prepares email content, THEN it MUST format content using the shared formatter.

#### Scenario: Attachment path containment

- GIVEN an attachment filename or generated path, WHEN report delivery writes the file, THEN it MUST use the safe path boundary from runtime-boundaries.

