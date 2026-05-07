# ai-progress-api-contract Specification

## Purpose
TBD - created by archiving change cr-ux-005-ai-waiting-states. Update Purpose after archive.
## Requirements
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

