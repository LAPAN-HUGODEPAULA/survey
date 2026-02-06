# screener-authentication Specification

## Purpose
TBD - created by archiving change add-screener-registration. Update Purpose after archive.
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

