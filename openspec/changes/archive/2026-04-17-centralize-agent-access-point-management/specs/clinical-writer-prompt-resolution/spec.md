## ADDED Requirements

### Requirement: Survey-driven Clinical Writer requests MUST resolve through builder-managed access points
For survey-driven report generation, the Clinical Writer runtime MUST resolve its effective `promptKey`, `personaSkillKey`, and `outputProfile` from builder-managed access-point configuration before consulting survey defaults or legacy fallbacks.

#### Scenario: Patient flow invokes a configured access point
- **WHEN** a survey-driven request reaches the backend with an `accessPointKey` that exists in the builder-managed configuration
- **THEN** the runtime MUST load the prompt stack defined for that access point
- **AND** it MUST use those resolved values when hydrating the Clinical Writer state

#### Scenario: Access point is missing for a migrated flow
- **WHEN** a migrated survey-driven flow invokes the runtime without a valid configured access point
- **THEN** the system MUST fail with an actionable configuration error or documented fallback behavior
- **AND** it MUST not silently substitute an unrelated prompt stack

### Requirement: Survey-driven runtime MUST use Mongo-managed catalogs as the primary source
Survey-driven Clinical Writer resolution MUST use Mongo-managed administrative catalogs as the primary prompt source for migrated flows, leaving Google Drive only as an explicit fallback for non-migrated or emergency scenarios.

#### Scenario: Mongo-backed configuration exists for a survey-driven flow
- **WHEN** the runtime resolves a survey-driven access point with valid catalog references in Mongo
- **THEN** the Clinical Writer MUST use the Mongo-backed prompt and persona definitions for that request
- **AND** it MUST not require Google Drive availability for the request to succeed
