## ADDED Requirements

### Requirement: The survey editor MUST allow administrators to configure default persona settings on a survey.

The `survey-builder` survey form MUST let administrators select a default `personaSkillKey` and `outputProfile` for each survey. The UI MUST persist those values through survey create and update requests and MUST reload them when an existing survey is reopened.

#### Scenario: User selects default persona settings for a survey
- **Given** persona skills exist in the catalog
- **When** the user edits a survey and selects a default persona skill and output profile
- **Then** the application MUST include those values in the survey create or update payload
- **And** it MUST show the saved settings when the survey is opened again

#### Scenario: User edits a survey without default persona settings
- **Given** a survey has no stored `personaSkillKey` or `outputProfile`
- **When** the user opens that survey in `survey-builder`
- **Then** the persona configuration controls MUST load with empty values
- **And** the rest of the survey editing flow MUST continue to work

#### Scenario: User selects an invalid or stale persona option
- **Given** a survey references a persona skill that no longer exists in the catalog
- **When** the user loads or saves that survey in `survey-builder`
- **Then** the application MUST surface a clear configuration error
- **And** it MUST NOT silently replace the missing persona with a different default

