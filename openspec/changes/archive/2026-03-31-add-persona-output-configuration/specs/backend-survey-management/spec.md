## ADDED Requirements

### Requirement: The survey management API MUST persist nullable default persona configuration on each survey.

Survey payloads MUST support nullable survey-level default `personaSkillKey` and `outputProfile` values so administrators can configure the default persona behavior for report generation without requiring request-level overrides on every submission.

These fields MUST remain backward compatible for surveys that do not yet define persona configuration.

#### Scenario: Create a survey with default persona configuration
- **Given** a persona skill exists in the persona catalog
- **When** a user creates a survey with `personaSkillKey` and `outputProfile`
- **Then** the system MUST persist those default persona settings with the survey
- **And** the created survey response MUST include the stored values

#### Scenario: Create a survey without persona configuration
- **Given** a user creates a survey without default persona settings
- **When** the survey payload omits `personaSkillKey` and `outputProfile` or sends them as `null`
- **Then** the system MUST accept the request
- **And** the stored survey MUST remain compatible with current fallback behavior

#### Scenario: Reject an unknown survey persona reference
- **Given** a survey payload references a `personaSkillKey` that does not exist in the persona catalog
- **When** the client submits the create or update request
- **Then** the system MUST reject the request with a clear configuration error

