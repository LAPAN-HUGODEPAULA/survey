## ADDED Requirements

### Requirement: Builder audit data MUST follow LGPD-aligned minimization rules
Persistent audit records for `survey-builder` administration MUST store only the minimum data required for traceability, governance, and incident response. Audit entries MUST avoid PHI, raw secrets, and full prompt bodies unless a stricter governance requirement explicitly demands them.

#### Scenario: Admin edits a persona skill
- **WHEN** the system records an audit event for a persona-skill update
- **THEN** the event MUST store stable identifiers, action metadata, actor identity, timestamp, and outcome
- **AND** it MUST NOT persist unrelated patient data or the full persona instructions by default

#### Scenario: Admin action carries sensitive payload fields
- **WHEN** a builder-managed request contains secret material, patient references, or large prompt content
- **THEN** the audit layer MUST redact, omit, or summarize those fields according to the governance policy before persistence

### Requirement: Builder audit retention and access MUST be restricted
Builder audit data MUST be retained for a defined governance period and MUST be accessible only to authorized operational or compliance roles.

#### Scenario: Unauthorized user attempts to access builder audit records
- **WHEN** a user without explicit audit-review permission attempts to query or export builder audit data
- **THEN** the system MUST deny access
- **AND** it MUST record the attempt according to the platform audit policy
