## ADDED Requirements
### Requirement: Session Lifecycle
The system SHALL manage consultation sessions using explicit lifecycle states.

#### Scenario: Create session
- **WHEN** a clinician starts a new consultation
- **THEN** the system creates a session with an initial state and timestamps

#### Scenario: Complete session
- **WHEN** a clinician finishes the consultation
- **THEN** the system marks the session as completed and records completion time

### Requirement: Session Persistence
The system SHALL persist session metadata and transcript references for the duration of the consultation.

#### Scenario: Refresh browser
- **WHEN** the clinician refreshes the page during an active session
- **THEN** the system restores the session state and message history

### Requirement: Optional Patient Linkage
The system SHALL allow sessions to be created with or without a linked patient.

#### Scenario: Create standalone session
- **WHEN** the clinician chooses to proceed without a patient
- **THEN** the system creates a session without patient linkage
