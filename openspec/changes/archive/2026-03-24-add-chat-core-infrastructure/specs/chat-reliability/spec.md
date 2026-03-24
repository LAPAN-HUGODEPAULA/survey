## ADDED Requirements
### Requirement: Data Integrity
The system SHALL ensure messages are not lost during transmission and are persisted in order.

#### Scenario: Retry on failure
- **WHEN** a message send fails due to a transient error
- **THEN** the system retries and preserves ordering

### Requirement: Session Recovery
The system SHALL recover active sessions after temporary connectivity loss.

#### Scenario: Reconnect after network loss
- **WHEN** the connection is restored
- **THEN** the system restores session state and pending messages

### Requirement: Availability Feedback
The system SHALL inform the clinician when connectivity is degraded.

#### Scenario: Offline indicator
- **WHEN** the client loses connection
- **THEN** the UI displays an offline indicator and disables send until recovery
