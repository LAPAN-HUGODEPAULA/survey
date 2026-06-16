# Screener Authentication & Profile Management Specification

## Purpose
Consolidates professional screener authentication models, council registration validation, settings pages, and profile UI screens.

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

### Requirement: Screener User Schema
The system MUST provide a schema for `Screener` users in the database.

#### Scenario: Create a new screener
**Given** a request to create a new screener with valid data
**When** the screener is saved to the database
**Then** the screener document MUST conform to the following structure:
```json
{
  "cpf": "11111111111",
  "firstName": "Maria",
  "surname": "Henriques Moreira Vale",
  "email": "maria.vale@holhos.com",
  "password": "<hashed_password>",
  "phone": "31988447613",
  "address": {
    "postalCode": "27090639",
    "street": "Praça da Liberdade",
    "number": "932",
    "complement": "",
    "neighborhood": "Copacabana",
    "city": "Uberlândia",
    "state": "MG"
  },
  "professionalCouncil": {
    "type": "CRP",
    "registrationNumber": "12543"
  },
  "jobTitle": "Psychologist",
  "degree": "Psychology",
  "darvCourseYear": 2019,
  "initialNoticeAcceptedAt": null
}
```

#### Scenario: Persist a screener that already accepted the initial notice
- **WHEN** the system stores or reads a screener record after the platform initial notice was accepted
- **THEN** the screener document MUST keep `initialNoticeAcceptedAt`
- **AND** the field MUST store the acknowledgement date and time in a consistent datetime format

### Requirement: Unique CPF
The `cpf` field MUST be unique for each screener.

#### Scenario: Create a screener with a duplicate CPF
**Given** a screener with CPF "111.111.111-11" already exists
**When** a request is made to create a new screener with the same CPF
**Then** the system MUST return an error indicating that the CPF is already in use.

### Requirement: Unique Email
The `email` field MUST be unique for each screener.

#### Scenario: Create a screener with a duplicate email
**Given** a screener with email "test@example.com" already exists
**When** a request is made to create a new screener with the same email
**Then** the system MUST return an error indicating that the email is already in use.

### Requirement: Settings Page Without Screener Fields
The `settings_page.dart` in `survey-frontend` MUST NOT include screener name or contact fields.

#### Scenario: View settings page
**Given** a user navigates to the settings page
**When** the page loads
**Then** the fields for screener name and contact MUST NOT be present.

### Requirement: Profile Menu
The top menu in `survey-frontend` and `clinical-narrative` MUST include a profile icon with shared authentication actions.

#### Scenario: View top menu as a logged-out user
**Given** a user is not logged in
**When** the user views the top menu in `survey-frontend` or `clinical-narrative`
**Then** a profile icon MUST be displayed
**And** opening the menu MUST expose entry points for sign-in and sign-up

#### Scenario: View top menu as a logged-in user
**Given** a screener is logged in
**When** the screener views the top menu in `survey-frontend` or `clinical-narrative`
**Then** a profile icon MUST be displayed
**And** opening the menu MUST expose actions for logout and account switching

### Requirement: Shared Professional Sign-In Surface
The platform MUST provide a shared professional sign-in surface in `packages/design_system_flutter` for the authenticated screener entry flow used by `survey-frontend` and `clinical-narrative`.

#### Scenario: Render the sign-in entry in either professional app
- **WHEN** an unauthenticated user opens the professional auth entry flow in `survey-frontend` or `clinical-narrative`
- **THEN** the app MUST render the canonical shared sign-in UI from `packages/design_system_flutter`
- **AND** the consuming app MUST keep ownership of navigation, repository calls, and session state wiring through callbacks or adapter contracts

### Requirement: Shared Professional Sign-Up Surface
The platform MUST provide a shared professional sign-up surface in `packages/design_system_flutter` for screener registration in `survey-frontend` and `clinical-narrative`.

#### Scenario: Render the registration entry in either professional app
- **WHEN** a user chooses to create a new professional account from `survey-frontend` or `clinical-narrative`
- **THEN** the app MUST render the canonical shared sign-up UI from `packages/design_system_flutter`
- **AND** the registration surface MUST collect the screener identity fields required by the existing screener registration contract

### Requirement: Shared Professional Auth Feedback States
The shared professional auth experience MUST present loading, validation, submission success, warning, and error feedback consistently across the professional apps through the canonical shared feedback model.

#### Scenario: Submit an auth form from a professional app
- **WHEN** the user submits the shared sign-in or sign-up form
- **THEN** the consuming app MUST be able to drive a standard loading state and structured validation feedback through the shared UI contract
- **AND** submission outcomes MUST be rendered through the canonical shared feedback surface with severity, icon, and readable body text

#### Scenario: Recoverable auth feedback is shown to the user
- **WHEN** the sign-in, sign-up, password-recovery, or initial-notice flow needs to present a success, warning, or error outcome
- **THEN** the shared auth UI MUST render that outcome with the same severity treatment used elsewhere in the platform
- **AND** the message MUST remain understandable without relying only on color

### Requirement: Shared Professional Initial Notice Gate
The platform MUST provide a shared professional initial-notice acknowledgement surface in `packages/design_system_flutter` for the post-login entry flow used by `survey-frontend` and `clinical-narrative`.

#### Scenario: Screener without a recorded agreement logs in
- **WHEN** an authenticated screener enters `survey-frontend` or `clinical-narrative` and their profile has no `initialNoticeAcceptedAt` value
- **THEN** the app MUST render the canonical shared initial-notice acknowledgement UI from `packages/design_system_flutter`
- **AND** the consuming app MUST keep ownership of navigation, repository calls, and session state wiring through callbacks or adapter contracts

#### Scenario: Screener with a recorded agreement logs in
- **WHEN** an authenticated screener enters `survey-frontend` or `clinical-narrative` and their profile already has an `initialNoticeAcceptedAt` value
- **THEN** the app MUST bypass the initial-notice gate
- **AND** it MUST allow the screener to proceed directly to the protected professional workflow
