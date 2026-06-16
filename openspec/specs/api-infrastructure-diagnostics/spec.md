# Engineering Infrastructure, API Contracts & Diagnostics Specification

## Purpose
Consolidates database migrations, import boundaries, Python service packaging, testing validation gates, async job progress APIs, and global error handling strategies.

## Requirements
### Requirement: Create Screeners Collection
A migration script MUST be created to create the `screeners` collection in the database.

#### Scenario: Run migration
**Given** the migration script is executed
**When** the migration completes
**Then** a new collection named `screeners` MUST exist in the database.

### Requirement: Add System Screener
The migration script MUST add the "System Screener" user to the `screeners` collection.

#### Scenario: Run migration
**Given** the migration script is executed
**When** the migration completes
**Then** the "System Screener" user MUST be present in the `screeners` collection.

### Requirement: Add Sample Screener
The migration script MUST add a sample screener user to the `screeners` collection for testing purposes.

#### Scenario: Run migration
**Given** the migration script is executed
**When** the migration completes
**Then** a sample screener user MUST be present in the `screeners` collection.

### Requirement: Migration scripts MUST create the QuestionnairePrompts and PersonaSkills collections.

The migration plan for the split prompt model MUST create MongoDB collections named `QuestionnairePrompts` and `PersonaSkills`.

#### Scenario: Run the prompt-storage migration
- **Given** the migration script is executed against an environment that does not yet use the split prompt model
- **When** the migration completes successfully
- **Then** the database MUST contain `QuestionnairePrompts`
- **And** the database MUST contain `PersonaSkills`

### Requirement: Migration scripts MUST backfill questionnaire prompts and seed persona skills without losing runtime traceability.

The migration MUST backfill questionnaire-specific prompt logic from existing prompt sources and seed persona skill documents for supported output profiles. The migrated data MUST preserve enough metadata to explain which legacy source produced each new document.

#### Scenario: Backfill an existing questionnaire prompt
- **Given** a questionnaire currently depends on a legacy survey prompt or hardcoded survey writer prompt
- **When** the migration runs
- **Then** the system MUST create or map a corresponding `QuestionnairePrompts` document
- **And** it MUST retain traceability to the legacy source used for the backfill

#### Scenario: Seed the school report persona
- **Given** the prompt-storage migration is executed
- **When** persona skills are seeded
- **Then** the system MUST create a `PersonaSkills` document for the school report output profile
- **And** that persona skill MUST be editable independently after migration

### Requirement: Add Screener Initial Notice Agreement Field
Migration scripts MUST add the platform-wide screener legal-notice acknowledgement field without losing existing screener data.

#### Scenario: Run migration on an existing screeners collection
- **WHEN** the migration executes against a database that already contains screener documents
- **THEN** the migration MUST add the nullable `initialNoticeAcceptedAt` field to legacy screener records
- **AND** existing screener data MUST remain intact

#### Scenario: Run migration after some screeners already have an acknowledgement date
- **WHEN** the migration executes against a database that already contains `initialNoticeAcceptedAt` values
- **THEN** the migration MUST preserve the stored acknowledgement dates
- **AND** it MUST remain safe to run without overwriting previously accepted records

### Requirement: Coverage Measurement
The system SHALL measure line and branch coverage for API, web, and mobile workspaces using platform-native tools.

#### Scenario: Generating workspace coverage reports
- **WHEN** tests are executed in a workspace
- **THEN** machine-readable and human-readable coverage reports are generated

### Requirement: CI Quality Gates
The CI pipeline SHALL enforce minimum test coverage thresholds and block builds that do not meet these targets.

#### Scenario: Build failure on low coverage
- **WHEN** a change reduces test coverage below the minimum threshold
- **THEN** the CI pipeline fails and reports the coverage gap

### Requirement: Full Matrix Execution
The CI pipeline SHALL successfully execute the full suite of backend, web, mobile, and workspace test commands.

#### Scenario: Successful full matrix run
- **WHEN** a change is proposed to the main branch
- **THEN** the full test matrix runs without unexpected failures

### Requirement: Clean Import Sets
All Flutter applications within the `apps/` directory SHALL be free of unused imports. This ensures that the codebase is lean and that the dependency graph is accurately represented.

#### Scenario: Automated Import Validation
- **WHEN** `flutter analyze` is executed in any application directory (`clinical-narrative`, `survey-builder`, `survey-frontend`, `survey-patient`)
- **THEN** the output SHALL NOT contain any "unused_import" diagnostics.

### Requirement: Functional Integrity Preservation
The process of removing unused imports SHALL NOT introduce side effects, modify application behavior, or alter the structural relationships between modules.

#### Scenario: Behavioral Regression Test
- **WHEN** dead imports are removed from a file
- **THEN** the application SHALL continue to compile without errors and maintain its existing routing and data flow behavior.

### Requirement: Service Dependency Manifest

Each backend service SHALL declare its runtime and development dependencies in a uv-managed manifest or workspace member.

#### Scenario: Runtime import declared

- GIVEN a production module imports a third-party package, WHEN dependency validation runs, THEN the package MUST be declared in that service runtime dependency set.

#### Scenario: Test import declared as dev

- GIVEN a test module imports pytest or test-only tools, WHEN dependency validation runs, THEN the package MUST be declared as a development dependency and not required by production runtime images.

### Requirement: First-Party Import Classification

Static analysis SHALL classify app and clinical_writer_agent as first-party imports for their owning services.

#### Scenario: Local app import

- GIVEN survey-backend imports app.*, WHEN static analysis runs from the repository or services root, THEN app MUST NOT be reported as a third-party package to install.

#### Scenario: Local clinical writer import

- GIVEN clinical-writer-api tests import clinical_writer_agent.*, WHEN static analysis runs, THEN clinical_writer_agent MUST NOT be reported as a hallucinated PyPI dependency.

### Requirement: Spec-to-Test Traceability Matrix
The system SHALL build and maintain a traceability matrix mapping every normative criterion in active OpenSpec specs to its coverage status (Covered, Partially Covered, Uncovered).

#### Scenario: Traceability matrix generation
- **WHEN** the traceability process runs
- **THEN** it outputs a mapping of spec criteria to existing or planned tests

### Requirement: Missing Scenario Implementation
The system SHALL ensure that tests are added for any unverified criteria, edge cases, and failure modes identified in the traceability matrix.

#### Scenario: Adding a test for an uncovered criterion
- **WHEN** a criterion is marked as Uncovered
- **THEN** a new test scenario is implemented to cover it

### Requirement: Cross-Layer Validation
The system SHALL implement tests at appropriate boundaries including unit, integration, and contract/API layers, prioritizing real interactions over excessive mocking for critical paths.

#### Scenario: Mock-heavy test audited and replaced
- **WHEN** an existing test relies heavily on mocks for critical business logic
- **THEN** it is replaced or supplemented by an integration or contract test that validates real system behavior

### Requirement: Test Effectiveness Reporting
The system SHALL generate a report detailing test findings, weak tests identified, and the rationale for refactor decisions.

#### Scenario: Effectiveness report generation
- **WHEN** the test effectiveness evaluation is complete
- **THEN** a report is published detailing findings and refactor actions

### Requirement: Medical Terminology Normalization
The system SHALL recognize and normalize medical terminology in pt-BR.

#### Scenario: Normalize terminology
- **WHEN** medical terms or abbreviations appear in the conversation
- **THEN** the system stores normalized equivalents alongside raw text

### Requirement: Negation Detection
The system SHALL detect negated findings to prevent false positives.

#### Scenario: Detect negation
- **WHEN** a clinician notes an absent symptom
- **THEN** the system records the symptom as negated

### Requirement: Temporal Relationship Extraction
The system SHALL extract temporal relationships for symptoms, treatments, and events.

#### Scenario: Extract temporal data
- **WHEN** timing or duration is mentioned
- **THEN** the system captures temporal relationships in structured form

### Requirement: Standardized Frontend-Safe Error Object
All platform APIs SHALL return a structured error object for non-2xx responses. This object MUST include fields that allow the frontend to provide specific, actionable guidance to the user without exposing sensitive technical details.

#### Scenario: Backend returns a validation error
- **WHEN** a request fails due to invalid input
- **THEN** the response body MUST include:
  - `code`: a stable string identifier (e.g., `VALIDATION_FAILED`)
  - `userMessage`: a localized, human-readable message in pt-BR
  - `severity`: one of `info`, `warning`, `error`
  - `retryable`: boolean indicating if the operation should be retried
  - `requestId`: a unique ID for correlation/support
  - `operation`: the name of the attempted action
  - `details`: (optional) list of field-specific validation errors

### Requirement: Categorization of Failure Types
API contracts MUST distinguish between different failure categories to drive appropriate frontend recovery journeys (e.g., re-authentication, refreshing an expired link, or notifying of maintenance).

#### Scenario: Access link has expired
- **WHEN** a user attempts to access a survey using an expired link
- **THEN** the API MUST return a `410 Gone` or `403 Forbidden` status
- **AND** the error object `code` MUST be `LINK_EXPIRED`
- **AND** the `retryable` field MUST be `false`.

#### Scenario: Upstream AI service is unavailable
- **WHEN** the `survey-backend` cannot reach the `clinical-writer-api`
- **THEN** the API MUST return a `503 Service Unavailable`
- **AND** the error object `code` MUST be `AI_SERVICE_UNAVAILABLE`
- **AND** the `retryable` field MUST be `true`.
- **AND** the `userMessage` MUST suggest waiting a few moments.

### Requirement: Microphone Error Handling
The system SHALL map common microphone errors into user-friendly messages in Brazilian Portuguese (pt-BR) and offer recovery paths (Retry).

#### Scenario: Permission denied
- **WHEN** the browser returns a microphone permission error
- **THEN** the system SHALL display guidance in pt-BR, a link to browser settings, and enable alternative text input.

#### Scenario: Microphone unavailable
- **WHEN** no audio device is detected
- **THEN** the system SHALL inform the user in pt-BR and suggest "Tentar Novamente" (Retry).

### Requirement: Transcription Error Handling
The system SHALL handle upload and transcription failures with standardized retries and a manual editing fallback.

#### Scenario: Upload failure
- **WHEN** the audio upload fails due to a network error
- **THEN** the system SHALL retry according to policy, display progress, and offer a manual "Tentar Novamente" button in pt-BR.

#### Scenario: Transcription failure
- **WHEN** the server fails to transcribe the audio
- **THEN** the system SHALL allow the user to manually write clinical notes and capture the failure reason.

### Requirement: Human-Readable Error Messages
The system SHALL replace technical error strings (e.g., "HTTP 500", "ConnectionTimeout") with user-friendly explanations in Brazilian Portuguese (pt-BR) that describe the problem and actions the user can take. API responses MUST use the standardized frontend-safe error object defined in `frontend-safe-error-contracts`.

#### Scenario: Internal server error
- **WHEN** a 500 error occurs on the backend
- **THEN** the system SHALL return a structured error response with `code: INTERNAL_SERVER_ERROR`
- **AND** the `userMessage` SHALL display: "Não foi possível completar esta ação agora. Nossos sistemas estão temporariamente indisponíveis. Tente novamente em alguns instantes."
- **AND** the `retryable` field MUST be set to `true`.

### Requirement: AI Processing Error Handling
The system SHALL handle AI generation and analysis failures with clear pt-BR messages and distinguish between transient (retryable) and permanent errors using the standardized error contract.

#### Scenario: Transient AI failure
- **WHEN** a temporary failure occurs in AI processing (e.g., timeout)
- **THEN** the system SHALL return an error object with `code: AI_TIMEOUT` and `retryable: true`
- **AND** the system SHALL display "Não foi possível concluir agora. Tente novamente em alguns instantes." and offer a `Tentar Novamente` button.

#### Scenario: Persistent AI failure
- **WHEN** the AI fails repeatedly or due to a content error (e.g., insufficient data)
- **THEN** the system SHALL return an error object with `code: AI_ANALYSIS_FAILED` and `retryable: false`
- **AND** the system SHALL display "Não conseguimos gerar a análise automática para este caso." and allow the user to continue manually or submit without the AI report.

### Requirement: AI Partial Results Handling
The system SHALL allow the user to utilize partial results or access the original data when full AI processing is not completed.

#### Scenario: Access to original data after AI failure
- **WHEN** AI report generation fails
- **THEN** the system SHALL ensure the user can still view and download the questionnaire responses.

### Requirement: Asynchronous Job Lifecycle for AI Tasks
Long-running AI operations (e.g., report generation, complex analysis) SHALL use an asynchronous pattern. The initial request MUST return a `202 Accepted` status with a `jobId` and a `statusUrl`.

#### Scenario: User initiates a clinical report
- **WHEN** the clinician clicks "Generate Report"
- **THEN** the API MUST return a `202 Accepted` response
- **AND** the payload MUST include a `jobId` for subsequent polling or WebSocket subscription.

### Requirement: Stage-Based Progress Updates
The API contract for AI jobs SHALL expose granular, human-readable processing stages. This allows the frontend to show specific waiting states (e.g., "Analyzing data", "Drafting narrative").

#### Scenario: Frontend polls for job status
- **WHEN** the app GETs the status of a `jobId`
- **THEN** the response MUST include:
  - `status`: one of `queued`, `processing`, `completed`, `failed`
  - `currentStage`: a string identifier (e.g., `analyzing`, `drafting`, `reviewing`)
  - `stageMessage`: a localized pt-BR string for display
  - `progressPercent`: (optional) numeric estimate
  - `estimatedRemainingSeconds`: (optional) duration estimate

### Requirement: Standardized AI Processing Stages
All AI-facing APIs SHALL use a standardized set of stages to ensure cross-app consistency in progress reporting.

#### Scenario: Clinical writer reports its progress
- **WHEN** the clinical writer agent moves from the Analyzer to the Writer node
- **THEN** the job status MUST transition from `analyzing` to `drafting`
- **AND** the `stageMessage` MUST update to "Escrevendo a primeira versão do documento."

### Requirement: Structured AI Error Contract
AI processing failures SHALL return an error object that classifies the recoverability of the problem.

#### Scenario: Transient AI Error
- **WHEN** the AI service fails due to timeout or overload
- **THEN** the API SHALL return a 503 error code with a `retryable: true` field
- **AND** SHALL provide a `userMessage` in pt-BR focused on retrying shortly.

### Requirement: Delayed and sparse polling for high-latency AI tasks
The system SHALL implement an optimized polling strategy for AI tasks that accounts for the high latency of reasoning models (~1 minute).

#### Scenario: Frontend initiates polling for complex analysis
- **WHEN** the frontend receives a `202 Accepted` response for an AI task
- **THEN** it SHALL wait at least 15 seconds before the first polling request
- **AND** subsequent polling requests SHALL occur at intervals of 10 seconds or more to reduce backend load

### Requirement: Stage Display via Stepper
Every flow involving long-duration AI processing (more than 3 seconds) SHALL display the current processing stage using a vertical `DsStepper` component (per CR-UX-004), mapping the real stages of the AI graph.

#### Scenario: View stages in questionnaire
- **WHEN** the user finalizes the questionnaire and the AI starts generating the report
- **THEN** the system SHALL sequentially show the stages in the stepper: "Organizando dados", "Analisando sinais", "Escrevendo rascunho", "Revisando conteúdo"
- **AND** SHALL use the Brazilian Portuguese (pt-BR) language.

### Requirement: Reassurance and Value Microcopy
Each AI waiting stage SHALL include contextualized reassurance microcopy using the `DsFeedback` component (per CR-UX-001) to explain the value of the current processing.

#### Scenario: Reassurance during clinical analysis
- **WHEN** the system is in the "Analisando sinais clínicos" stage
- **THEN** the system SHALL display: "Estamos analisando os sinais principais do caso para uma leitura inicial mais cuidadosa."
- **AND** the message SHALL have `info` or `processing` severity.

### Requirement: Form Submission Cycle Integration
The AI waiting state SHALL immediately succeed the form `submitted` state (per CR-UX-003), ensuring there is no visual vacuum between data submission and the start of processing.

#### Scenario: Transition from questionnaire to analysis
- **WHEN** the backend confirms receipt (`submitted`)
- **THEN** the UI SHALL transition smoothly to the `DsAIProgressIndicator`
- **AND** SHALL provide "Wayfinding" guidance (CR-UX-004) if the user can continue navigating.

### Requirement: Standardized AI Error Management
AI processing failures SHALL be communicated via `DsFeedback` (CR-UX-001), distinguishing between recoverable errors (automatic retry) and fatal errors.

#### Scenario: Timeout failure in analysis
- **WHEN** the analysis exceeds the allowed timeout
- **THEN** the system SHALL display feedback with `warning` severity
- **AND** SHALL offer the option to "Tentar Novamente" manually.
