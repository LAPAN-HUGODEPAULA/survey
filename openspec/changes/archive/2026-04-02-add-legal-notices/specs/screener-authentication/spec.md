## ADDED Requirements

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
