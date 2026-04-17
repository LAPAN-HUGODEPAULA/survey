# screener-authentication Specification

## Purpose
Define the backend authentication and registration contract for screeners across the LAPAN professional applications.
## Requirements
### Requirement: Screener Login
The system MUST provide a mechanism for screeners to log in. Failed login attempts MUST return a structured error object that allows the frontend to distinguish between invalid credentials, locked accounts, and unverified emails.

#### Scenario: Successful login
**Given** a registered screener with email "test@example.com" and password "password123"
**When** the screener logs in with the correct credentials
**Then** the system MUST return a JWT (JSON Web Token) for authentication.

#### Scenario: Unsuccessful login due to invalid credentials
**Given** a registered screener
**When** the screener attempts to log in with an incorrect password
**Then** the system MUST return a `401 Unauthorized` status
**AND** the error object `code` MUST be `INVALID_CREDENTIALS`
**AND** the `retryable` field MUST be `true`.

### Requirement: Password Encryption
The system MUST encrypt screener passwords before storing them in the database.

#### Scenario: Password is hashed
**Given** a new screener is being registered
**When** the screener's data is saved
**Then** the `password` field in the database MUST contain a hashed version of the original password.

### Requirement: Password Recovery (Contract Transition)
The system SHALL provide a mechanism for screeners to recover their password. The API contract SHALL prioritize a **tokenized reset-link flow** over generating a replacement password.

#### Scenario: Request password recovery link
- **WHEN** a screener requests password recovery
- **THEN** the system MUST return a `200 OK` or `202 Accepted` response
- **AND** the backend SHALL generate a temporary secure token and initiate the email delivery of a reset link
- **AND** the API response MUST NOT confirm if the email exists for security reasons, returning a generic success `userMessage` in pt-BR.

### Requirement: Shared Screener Authentication Across Professional Apps
The existing screener authentication contract MUST serve both `survey-frontend` and `clinical-narrative` without introducing a second professional identity store.

#### Scenario: Existing screener signs into the clinical narrative app
- **WHEN** a registered screener signs into `clinical-narrative` with valid platform credentials
- **THEN** the app MUST authenticate against the existing screener backend contract
- **AND** the authenticated user MUST be resolved from the existing screener identity model rather than a new clinician-specific collection

### Requirement: Shared Screener Registration Entry Across Professional Apps
The existing screener registration contract MUST be reachable from both `survey-frontend` and `clinical-narrative`.

#### Scenario: Register from either professional app
- **WHEN** a user completes screener registration from `survey-frontend` or `clinical-narrative`
- **THEN** the submitted data MUST target the existing screener registration contract
- **AND** the new account MUST be created in the existing `screeners` collection

### Requirement: Screener Legal-Notice Acknowledgement Contract
The authenticated screener contract MUST expose the platform-wide initial-notice acknowledgement state and MUST provide an authenticated write path to record the first acknowledgement.

#### Scenario: Read screener legal-notice acknowledgement state
- **WHEN** a professional app retrieves the authenticated screener profile
- **THEN** the screener payload MUST include the nullable `initialNoticeAcceptedAt` field
- **AND** the value MUST be empty until the screener has acknowledged the platform initial notice

#### Scenario: Record first screener acknowledgement
- **WHEN** an authenticated screener accepts the initial notice in `survey-frontend` or `clinical-narrative`
- **THEN** the backend MUST persist the acknowledgement using a server-generated timestamp in `initialNoticeAcceptedAt`
- **AND** the acknowledgement MUST apply platform-wide to both professional apps

#### Scenario: Re-submit acknowledgement after it is already recorded
- **WHEN** an authenticated screener submits the acknowledgement write path after `initialNoticeAcceptedAt` is already set
- **THEN** the backend MUST return the existing acknowledgement state without requiring a second acceptance record

### Requirement: Screener authentication contract MUST support survey-builder admin bootstrap
The existing screener authentication contract MUST support `survey-builder` as a professional client that can sign in, resolve the authenticated screener profile, and determine whether the session may proceed into admin-only workflows.

#### Scenario: Builder resolves authenticated screener profile
- **WHEN** `survey-builder` completes screener login or restores a stored token
- **THEN** the existing screener authentication stack MUST allow the app to retrieve the authenticated screener profile
- **AND** the returned profile MUST be usable by the builder authorization layer to decide whether the screener is the allowed admin

#### Scenario: Builder reuses professional session semantics
- **WHEN** a valid screener session already exists from a supported professional flow
- **THEN** `survey-builder` MUST be able to reuse that session contract
- **AND** it MUST not require a second builder-specific credential or identity record

