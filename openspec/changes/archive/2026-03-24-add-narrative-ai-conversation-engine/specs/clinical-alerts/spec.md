## ADDED Requirements
### Requirement: Clinical Alert Generation
The system SHALL generate alerts for safety-relevant issues such as interactions, contraindications, and red flags.

#### Scenario: Generate alert
- **WHEN** risky combinations or red flag symptoms are detected
- **THEN** the system presents a clinical alert with severity level

### Requirement: Alert Acknowledgment
The system SHALL require explicit acknowledgment for critical alerts.

#### Scenario: Acknowledge critical alert
- **WHEN** a critical alert is shown
- **THEN** the clinician must acknowledge it before proceeding
