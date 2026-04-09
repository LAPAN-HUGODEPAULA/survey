# survey-report-prompt-selection Specification

## Purpose
This specification defines how the system selects and applies the correct AI prompt when generating clinical reports from survey responses.
## Requirements
### Requirement: Survey-based report flows MUST resolve questionnaire logic and output persona separately.

Survey-based report generation MUST treat questionnaire clinical logic and output-profile persona as separate runtime inputs. The questionnaire determines the `QuestionnairePrompt`, while the report flow determines the `PersonaSkill` for the desired output profile.

When a survey stores default `personaSkillKey` or `outputProfile` configuration, the system MUST use those survey defaults before applying legacy hardcoded persona fallback rules.

#### Scenario: Generate a school report from a questionnaire response
- **Given** a questionnaire response has been submitted successfully
- **And** the questionnaire has a configured `QuestionnairePrompt`
- **And** the report flow selects the school report output profile
- **When** the AI generation flow starts
- **Then** the system MUST resolve the questionnaire prompt separately from the school report persona skill
- **And** it MUST avoid relying on a single hardcoded prompt to supply both concerns

#### Scenario: No explicit persona override is supplied but the survey has defaults
- **Given** a survey-derived request has no request-level `personaSkillKey` or `outputProfile`
- **And** the survey stores default persona configuration
- **When** report generation starts
- **Then** the system MUST use the survey defaults before consulting legacy hardcoded mappings

### Requirement: Survey report generation MUST propagate questionnaire prompt identity and persona skill identity end to end.

The survey backend and worker MUST carry the questionnaire prompt identifier and the persona skill identifier through AI enrichment so the generated report reflects both the clinical logic of the questionnaire and the stylistic constraints of the selected output profile.

Request-level `personaSkillKey` or `outputProfile` values MUST override survey defaults. When neither request-level nor survey-level persona settings are present, the system MUST preserve current fallback behavior. When a survey-level `personaSkillKey` is configured but no longer resolves to a known persona skill, the system MUST return a clear configuration error instead of silently falling back.

#### Scenario: Submit a survey response for school-report generation
- **Given** the survey flow has resolved both a questionnaire prompt and a school-report persona skill
- **When** the system submits the request for AI enrichment
- **Then** it MUST send both identifiers through the backend and worker path
- **And** the Clinical Writer MUST use those identifiers to resolve the final runtime prompt

#### Scenario: Request-level persona settings override survey defaults
- **Given** a survey stores default `personaSkillKey` or `outputProfile`
- **And** the incoming request explicitly provides `personaSkillKey` or `outputProfile`
- **When** report generation starts
- **Then** the system MUST use the request-level values instead of the survey defaults

#### Scenario: No explicit persona skill is supplied anywhere
- **Given** a survey-derived request has a questionnaire prompt
- **And** neither the request nor the survey provides persona configuration
- **When** report generation starts
- **Then** the system MUST use the default persona skill configured for that report flow or return a clear configuration error
- **And** it MUST NOT silently collapse persona selection back into hardcoded LangGraph prompt text

#### Scenario: Survey references a deleted persona skill
- **Given** a survey stores a `personaSkillKey` that no longer exists in the persona catalog
- **When** report generation starts without a request-level persona override
- **Then** the system MUST return a clear configuration error
- **And** it MUST NOT silently fall back to a different persona

