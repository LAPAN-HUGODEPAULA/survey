## ADDED Requirements

### Requirement: Survey completion handoff MUST use explicit access-point keys for agent routing
Patient and screener survey-completion flows that trigger Clinical Writer processing MUST identify the target agent entry point using a stable `accessPointKey` rather than relying only on implicit prompt selection.

#### Scenario: Patient thank-you flow starts analysis
- **WHEN** the `survey-patient` thank-you flow requests a preliminary analysis
- **THEN** the request MUST identify the configured patient-facing access point for that handoff
- **AND** the backend MUST resolve the runtime prompt stack from that access-point configuration

#### Scenario: Screener-triggered report flow starts analysis
- **WHEN** a survey-completion flow in `survey-frontend` requests report generation
- **THEN** the request MUST identify the configured screener-facing access point for that workflow
- **AND** the runtime MUST not depend exclusively on a frontend-selected `promptKey`
