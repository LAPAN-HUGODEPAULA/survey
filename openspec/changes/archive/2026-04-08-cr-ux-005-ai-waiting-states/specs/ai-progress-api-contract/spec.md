## ADDED Requirements

### Requirement: AI Processing Stage Reporting
AI services SHALL expose the current stage of long-running processing to the frontend client.

#### Scenario: Query stage via polling
- **WHEN** the frontend submits an analysis request
- **THEN** the backend SHALL return a task ID and expose a `/status/{task_id}` endpoint
- **AND** the status response SHALL include a `stage` field (e.g., `analyzing`, `drafting`) and an optional `percent` field.

### Requirement: Structured AI Error Contract
AI processing failures SHALL return an error object that classifies the recoverability of the problem.

#### Scenario: Transient AI Error
- **WHEN** the AI service fails due to timeout or overload
- **THEN** the API SHALL return a 503 error code with a `retryable: true` field
- **AND** SHALL provide a `userMessage` in pt-BR focused on retrying shortly.
