## ADDED Requirements

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
