## Why

Currently, many UX improvements are blocked because backend API contracts lack the state richness required for a trustworthy and informative user experience. Long-running AI operations are synchronous, error messages are flattened too early, and the frontend cannot distinguish between retryable and permanent failures. This proposal establishes a standardized, UX-supporting contract for errors, progress, and recovery across the platform.

## What Changes

- **Standardized Error Object**: Define a shared error contract across all APIs including `code`, `userMessage`, `severity`, `retryable`, `requestId`, `operation`, and `stage`.
- **Asynchronous AI Operations**: Transition long-running AI tasks (like report generation and chat analysis) from synchronous to asynchronous job patterns.
- **Stage-Based Progress API**: Implement an endpoint or streaming mechanism to expose granular stage updates (e.g., `validating`, `analyzing`, `drafting`) for long tasks.
- **Enhanced Recovery Contracts**: Update contracts to explicitly distinguish between empty data, unauthorized access, expired links, and backend unavailability to drive appropriate frontend recovery flows.
- **Tokenized Password Reset (Contract)**: Prepare the API contract for a transition from "replacement password" to "tokenized reset link" flows.

## Capabilities

### New Capabilities
- `frontend-safe-error-contracts`: Defines the structured error schema and mapping rules for user-facing failures.
- `ai-progress-api-contract`: Establishes the contract for stage-based progress reporting for asynchronous AI jobs.

### Modified Capabilities
- `error-handling`: Update platform-wide error handling requirements to use the new structured error object.
- `generate-clinical-documents`: Transition document generation from synchronous to asynchronous processing with status polling.
- `clinical-writer-prompt-resolution`: Update the clinical writer API to expose processing stages.
- `screener-authentication`: Update authentication contracts to support richer failure states and prepare for tokenized recovery.

## Impact

- **Affected Services**: `survey-backend`, `clinical-writer-api`
- **Affected Packages**: `packages/contracts` (OpenAPI definitions)
- **Affected Apps**: All frontends will eventually consume the richer error and progress data.
- **Breaking Changes**: **BREAKING** changes to error response schemas and long-running AI endpoints.
