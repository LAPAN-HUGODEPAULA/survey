# ai-job-resilience Specification

## Purpose
Define the requirements for handling failures and retries of background AI jobs, ensuring reliability and limiting resource consumption.

## Requirements

### Requirement: Limited Retries for AI Jobs
The background worker SHALL limit the number of processing attempts for a single document to prevent infinite token consumption.

#### Scenario: Document fails repeatedly
- **WHEN** a survey response processing fails and reaches `WORKER_MAX_RETRIES`
- **THEN** the system MUST increment the `retryCount` up to the configured maximum
- **AND** it MUST set the `agentResponseStatus` to `permanently_failed`
- **AND** it MUST stop polling this document for automatic processing

#### Scenario: Debug mode retry limit is reduced
- **WHEN** the environment sets `WORKER_MAX_RETRIES=1`
- **THEN** the worker MUST stop automatic retries after the first failed attempt

### Requirement: Failure Context Recording
The system SHALL record the reason for failure to aid in administrative diagnosis.

#### Scenario: Processing failure
- **WHEN** the `survey-worker` encounters an error while calling the Clinical Writer
- **THEN** it MUST store the error message in the `lastError` field of the document
- **AND** update the `agentResponseUpdatedAt` timestamp

### Requirement: Worker diagnostics logging MUST be runtime-configurable
The worker SHALL provide runtime flags to enable or disable detailed payload and response logging without recompilation.

#### Scenario: Payload and response logging enabled for investigation
- **WHEN** diagnostic logging flags are enabled
- **THEN** the worker MUST log outbound agent payload, raw agent response, and normalized response
- **AND** the worker MUST include failure context with request identifiers to aid debugging malformed responses

#### Scenario: Payload and response logging disabled
- **WHEN** diagnostic logging flags are disabled
- **THEN** the worker MUST keep concise operational logs without verbose payload dumps
