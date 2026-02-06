## ADDED Requirements
### Requirement: Clinical Session Creation
The system SHALL allow starting a new session with or without a patient link.

#### Scenario: Start session without patient
- **WHEN** the clinician chooses to start without a patient
- **THEN** the session is created without identifiable data

#### Scenario: Start session with patient
- **WHEN** the clinician selects a patient
- **THEN** the session is created with loaded context

### Requirement: Session Header
The system SHALL display a header with session status, duration, and primary actions.

#### Scenario: Active session
- **WHEN** the session is active
- **THEN** the header shows status, duration, and available actions

#### Scenario: Finished session
- **WHEN** the session is completed
- **THEN** the header shows a finished status and input is disabled
