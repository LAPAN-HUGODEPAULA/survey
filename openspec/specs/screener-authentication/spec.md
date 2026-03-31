# screener-authentication Specification

## Purpose
Define the backend authentication and registration contract for screeners across the LAPAN professional applications.
## Requirements
### Requirement: Screener Login
The system MUST provide a mechanism for screeners to log in.

#### Scenario: Successful login
**Given** a registered screener with email "test@example.com" and password "password123"
**When** the screener logs in with the correct credentials
**Then** the system MUST return a JWT (JSON Web Token) for authentication.

#### Scenario: Unsuccessful login
**Given** a registered screener with email "test@example.com" and password "password123"
**When** the screener attempts to log in with an incorrect password
**Then** the system MUST return an authentication error.

### Requirement: Password Encryption
The system MUST encrypt screener passwords before storing them in the database.

#### Scenario: Password is hashed
**Given** a new screener is being registered
**When** the screener's data is saved
**Then** the `password` field in the database MUST contain a hashed version of the original password.

### Requirement: Password Recovery
The system MUST provide a mechanism for screeners to recover their password.

#### Scenario: Request password recovery
**Given** a registered screener with email "test@example.com"
**When** the screener requests a password recovery
**Then** the system MUST generate a new random password and send it to "test@example.com".

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
