## ADDED Requirements

### Requirement: Administrative configuration changes MUST be included in the platform audit trail
The platform audit trail MUST include privileged configuration changes originating from `survey-builder`, including prompt, persona, survey, output-profile, and access-point administration as those resources become available.

#### Scenario: Builder persists a configuration write
- **WHEN** a privileged builder API request creates, updates, publishes, or deletes an administrative configuration resource
- **THEN** the platform MUST record a persistent audit event for that write
- **AND** the event MUST be attributable to the authenticated builder admin identity

### Requirement: Builder audit events MUST support operational investigation
Builder audit events MUST capture request correlation identifiers and normalized outcome codes so operators can join audit evidence with backend traces during incident response.

#### Scenario: Support team investigates a failed admin write
- **WHEN** an operator reviews a failed builder configuration change
- **THEN** the audit record MUST include a correlation id or equivalent trace key
- **AND** the outcome metadata MUST distinguish validation failure, authorization denial, and internal error outcomes
