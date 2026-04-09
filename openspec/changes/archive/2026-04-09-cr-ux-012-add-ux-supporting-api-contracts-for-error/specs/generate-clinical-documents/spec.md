## MODIFIED Requirements

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
