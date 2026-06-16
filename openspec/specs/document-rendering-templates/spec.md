# Document Template Management & Rendering Specification

## Purpose
Consolidates template schema definition, versioning, clinical document generation workflow, output rendering (PDF/print), metadata embedding, and report delivery mechanisms.

## Requirements
### Requirement: Legal Fields
The system SHALL enforce inclusion of required legal fields such as clinician identity, CRM, and dates.

#### Scenario: Validate legal fields
- **WHEN** a document is generated
- **THEN** the system blocks generation if required fields are missing

### Requirement: Confidentiality Notice
The system SHALL include a confidentiality notice on clinical documents.

#### Scenario: Add confidentiality notice
- **WHEN** a document is rendered
- **THEN** the output includes a confidentiality notice in the footer

### Requirement: Metadata Capture
The system SHALL store document metadata including template version, session ID, author, and creation time.

#### Scenario: Store metadata
- **WHEN** a document is generated
- **THEN** the system records metadata alongside the document record

### Requirement: Metadata Embedding
The system SHALL embed key metadata in PDF outputs when supported.

#### Scenario: Embed metadata in PDF
- **WHEN** a PDF is generated
- **THEN** the file includes document type, author, and creation date

### Requirement: PDF Export
The system SHALL generate PDF documents suitable for medical records and archiving.

#### Scenario: Export PDF
- **WHEN** a clinician confirms document generation
- **THEN** the system produces a PDF file and initiates download

### Requirement: Browser Print
The system SHALL support direct printing with print-optimized layout.

#### Scenario: Print document
- **WHEN** a clinician selects print
- **THEN** the system opens a print view with correct page breaks and headers

### Requirement: Placeholder Rendering
The system SHALL replace template placeholders with actual data, applying formatting rules.

#### Scenario: Render placeholders
- **WHEN** a template is rendered
- **THEN** placeholders are replaced with values or configured fallbacks

### Requirement: Medical Formatting
The system SHALL apply medical document conventions (sections, signatures, units, and dates).

#### Scenario: Apply medical formatting
- **WHEN** a document is rendered
- **THEN** the output follows Brazilian medical document conventions

### Requirement: Document Generation Flow
The system SHALL provide a guided workflow to select templates, preview output, and confirm document generation.

#### Scenario: Generate document
- **WHEN** a clinician selects "Generate Document"
- **THEN** the system shows template suggestions, a preview, and a confirmation step

### Requirement: Data Mapping
The system SHALL map consultation data and extracted entities to template variables before rendering.

#### Scenario: Map consultation data
- **WHEN** a document preview is requested
- **THEN** the system maps transcript, entities, and patient data into template variables

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

#### Scenario: Export document to PDF
- **WHEN** the user requests a PDF export
- **THEN** the system SHALL compile the clinical document and prompt a local PDF download

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

### Requirement: Template Registration
The system SHALL allow authorized administrators to create and edit templates.

#### Scenario: Create template
- **WHEN** an administrator saves a new template
- **THEN** the system records the template with version metadata

### Requirement: Document Types
The system SHALL support at least six clinical document types.

#### Scenario: List supported types
- **WHEN** the administrator configures a template
- **THEN** the system offers types: visit note, prescription, referral, certificate, report/opinion, and clinical evolution

### Requirement: System MUST expose screener preliminary analysis access point defaults
The access point "Análise automática do questionário profissional" (key `survey_frontend.thank_you.auto_analysis`) SHALL remain available for screener flows and MUST default to prompt `triagem de pacientes` and persona `patient_condition_overview`.

#### Scenario: Preliminary analysis access point defaults are resolved
- **WHEN** the screener thank-you page requests automatic preliminary analysis
- **THEN** the system MUST resolve the configured access point for `survey_frontend.thank_you.auto_analysis`
- **AND** if no custom override exists, the default prompt MUST be `triagem de pacientes`
- **AND** if no custom override exists, the default persona MUST be `patient_condition_overview`

#### Scenario: Access point is configurable in survey-builder
- **WHEN** an admin opens access point management in survey-builder
- **THEN** `RuntimeAccessPointCatalog` MUST include `survey_frontend.thank_you.auto_analysis` for configuration
- **AND** admin updates MUST persist without requiring backend code changes

### Requirement: System MUST provide a detailed report access point for survey-frontend
The backend SHALL seed an access point with key `screener.report.detailed_analysis` that uses the `full_intake` prompt and `clinical_diagnostic_report` persona. This access point is used by the "Gerar Relatório" button on the screener thank-you page.

#### Scenario: Access point is seeded and available
- **WHEN** the seed script runs
- **THEN** the `agent_access_points` collection MUST contain a document with `accessPointKey: "screener.report.detailed_analysis"`
- **AND** `promptKey` MUST be `"full_intake"`
- **AND** `personaSkillKey` MUST be `"clinical_diagnostic_report"`
- **AND** `outputProfile` MUST be `"clinical_diagnostic_report"`

#### Scenario: Access point is configurable in survey-builder
- **WHEN** an admin opens the access point form in survey-builder
- **THEN** `RuntimeAccessPointCatalog` MUST include `screener.report.detailed_analysis` as a configurable entry
- **AND** the admin MUST be able to select it from the injection point dropdown

### Requirement: System MUST provide a clinical referral letter access point
The backend SHALL seed an access point with key `screener.document.clinical_referral` for generating clinical referral letters.

#### Scenario: Access point is seeded and available
- **WHEN** the seed script runs
- **THEN** the `agent_access_points` collection MUST contain a document with `accessPointKey: "screener.document.clinical_referral"`
- **AND** the access point MUST be bound to an appropriate prompt and persona for clinical referral letter generation

#### Scenario: Access point is configurable in survey-builder
- **WHEN** an admin opens the access point form in survey-builder
- **THEN** `RuntimeAccessPointCatalog` MUST include `screener.document.clinical_referral` as a configurable entry

### Requirement: System MUST provide a school referral letter access point
The backend SHALL seed an access point with key `screener.document.school_referral` for generating school referral letters.

#### Scenario: Access point is seeded and available
- **WHEN** the seed script runs
- **THEN** the `agent_access_points` collection MUST contain a document with `accessPointKey: "screener.document.school_referral"`
- **AND** the access point MUST be bound to an appropriate prompt and persona for school referral letter generation

#### Scenario: Access point is configurable in survey-builder
- **WHEN** an admin opens the access point form in survey-builder
- **THEN** `RuntimeAccessPointCatalog` MUST include `screener.document.school_referral` as a configurable entry

### Requirement: System MUST provide a parent orientation letter access point
The backend SHALL seed an access point with key `screener.document.parent_orientation` for generating parent orientation letters.

#### Scenario: Access point is seeded and available
- **WHEN** the seed script runs
- **THEN** the `agent_access_points` collection MUST contain a document with `accessPointKey: "screener.document.parent_orientation"`
- **AND** the access point MUST be bound to an appropriate prompt and persona for parent orientation letter generation

#### Scenario: Access point is configurable in survey-builder
- **WHEN** an admin opens the access point form in survey-builder
- **THEN** `RuntimeAccessPointCatalog` MUST include `screener.document.parent_orientation` as a configurable entry

### Requirement: survey-builder MUST handle new screener access points gracefully
When an admin configures the new screener access points, the survey-builder SHALL support both create and update modes.

#### Scenario: Admin creates a new screener access point
- **WHEN** an admin selects a screener injection point that does not yet exist in the database
- **THEN** the survey-builder MUST use POST to create the access point

#### Scenario: Admin updates an existing screener access point
- **WHEN** an admin selects a screener injection point that already exists
- **THEN** the survey-builder MUST detect the existing record
- **AND** the survey-builder MUST use PUT to update instead of POST
- **AND** the form MUST NOT show a 409 error

### Requirement: Versioning
The system SHALL maintain version history for templates using semantic versioning.

#### Scenario: Edit template
- **WHEN** an administrator edits a template
- **THEN** the system creates a new version and preserves prior versions

### Requirement: Approval Workflow
The system SHALL require approval before a template becomes active.

#### Scenario: Approve template
- **WHEN** an administrator approves a template draft
- **THEN** the template status changes to active and is visible to clinicians

### Requirement: Archival
The system SHALL allow administrators to archive templates instead of hard deletion.

#### Scenario: Archive template
- **WHEN** an administrator archives a template
- **THEN** the template is hidden from clinician selection but remains stored for audit

### Requirement: Access Control
The system SHALL enforce role-based access control for template operations.

#### Scenario: Non-admin edits template
- **WHEN** a non-admin attempts to edit a template
- **THEN** the system denies the action and logs the attempt

### Requirement: Audit Logging
The system SHALL record audit events for template creation, updates, approvals, and archival.

#### Scenario: Record audit event
- **WHEN** a template is approved
- **THEN** the system records the approver, timestamp, and template version

### Requirement: Template Discovery
The system SHALL allow clinicians to browse, filter, and search active templates.

#### Scenario: Filter by document type
- **WHEN** a clinician filters templates by type
- **THEN** only matching active templates are shown

### Requirement: Template Preview
The system SHALL allow clinicians to preview templates before selection.

#### Scenario: Preview template
- **WHEN** a clinician requests a preview
- **THEN** the system renders the template using available session data

### Requirement: Recommendations
The system SHALL suggest relevant templates based on consultation context when available.

#### Scenario: Suggest template
- **WHEN** consultation context indicates a likely document type
- **THEN** the system presents recommended templates ranked by relevance

### Requirement: Template Schema
The system SHALL store templates with structured fields for metadata, content, variables, and conditions.

#### Scenario: Persist template schema
- **WHEN** a template is saved
- **THEN** the system validates required fields and stores the structured schema

### Requirement: Placeholders
The system SHALL support placeholders for patient, clinician, and consultation data.

#### Scenario: Render placeholders
- **WHEN** a template is rendered with session data
- **THEN** placeholders are replaced with available values

### Requirement: Conditional Sections
The system SHALL support conditional sections based on clinical context.

#### Scenario: Evaluate conditional section
- **WHEN** a condition evaluates to false
- **THEN** the system omits the conditional section from output

### Requirement: Supported Document Types
The system SHALL support at least six document types for templates: consultation record, prescription, referral, certificate, technical report, and clinical progress.

#### Scenario: List document types
- **WHEN** an administrator creates a new template
- **THEN** the system presents the supported document types

### Requirement: Template Ownership
The system SHALL restrict template creation and management to administrators.

#### Scenario: Clinician attempts to create template
- **WHEN** a clinician attempts to create a template
- **THEN** the system denies the action with an authorization error

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
