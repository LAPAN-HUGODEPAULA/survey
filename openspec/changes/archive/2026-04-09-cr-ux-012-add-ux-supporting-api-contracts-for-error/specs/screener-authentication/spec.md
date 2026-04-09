## MODIFIED Requirements

### Requirement: Screener Login
The system MUST provide a mechanism for screeners to log in. Failed login attempts MUST return a structured error object that allows the frontend to distinguish between invalid credentials, locked accounts, and unverified emails.

#### Scenario: Unsuccessful login due to invalid credentials
**Given** a registered screener
**When** the screener attempts to log in with an incorrect password
**Then** the system MUST return a `401 Unauthorized` status
**AND** the error object `code` MUST be `INVALID_CREDENTIALS`
**AND** the `retryable` field MUST be `true`.

### Requirement: Password Recovery (Contract Transition)
The system SHALL provide a mechanism for screeners to recover their password. The API contract SHALL prioritize a **tokenized reset-link flow** over generating a replacement password.

#### Scenario: Request password recovery link
- **WHEN** a screener requests password recovery
- **THEN** the system MUST return a `200 OK` or `202 Accepted` response
- **AND** the backend SHALL generate a temporary secure token and initiate the email delivery of a reset link
- **AND** the API response MUST NOT confirm if the email exists for security reasons, returning a generic success `userMessage` in pt-BR.
