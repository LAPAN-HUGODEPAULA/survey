# survey-report-prompt-selection Specification

## Purpose
This specification defines how the system selects and applies the correct AI prompt when generating clinical reports from survey responses.
## Requirements
### Requirement: Survey-based report flows MUST resolve questionnaire logic and output persona separately.

Survey-based report generation MUST treat questionnaire clinical logic and output-profile persona as separate runtime inputs. The questionnaire determines the `QuestionnairePrompt`, while the report flow determines the `PersonaSkill` for the desired output profile.

#### Scenario: Generate a school report from a questionnaire response
- **Given** a questionnaire response has been submitted successfully
- **And** the questionnaire has a configured `QuestionnairePrompt`
- **And** the report flow selects the school report output profile
- **When** the AI generation flow starts
- **Then** the system MUST resolve the questionnaire prompt separately from the school report persona skill
- **And** it MUST avoid relying on a single hardcoded prompt to supply both concerns

### Requirement: Survey report generation MUST propagate questionnaire prompt identity and persona skill identity end to end.

The survey backend and worker MUST carry the questionnaire prompt identifier and the persona skill identifier through AI enrichment so the generated report reflects both the clinical logic of the questionnaire and the stylistic constraints of the selected output profile.

#### Scenario: Submit a survey response for school-report generation
- **Given** the survey flow has resolved both a questionnaire prompt and a school-report persona skill
- **When** the system submits the request for AI enrichment
- **Then** it MUST send both identifiers through the backend and worker path
- **And** the Clinical Writer MUST use those identifiers to resolve the final runtime prompt

#### Scenario: No explicit persona skill is supplied
- **Given** a survey-derived request has a questionnaire prompt but no explicit persona skill identifier
- **When** report generation starts
- **Then** the system MUST use the default persona skill configured for that report flow or return a clear configuration error
- **And** it MUST NOT silently collapse persona selection back into hardcoded LangGraph prompt text

