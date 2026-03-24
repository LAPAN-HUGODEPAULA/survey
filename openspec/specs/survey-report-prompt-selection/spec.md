# survey-report-prompt-selection Specification

## Purpose
TBD - created by archiving change add-survey-ai-prompts. Update Purpose after archive.
## Requirements
### Requirement: Survey-based report flows MUST expose the questionnaire's available AI report outcomes.

The `survey-frontend` and `survey-patient` applications MUST use the questionnaire's stored prompt associations to determine which AI report outcomes can be generated for a submitted response.

#### Scenario: Questionnaire has multiple associated outcomes
- **Given** a survey response has been submitted successfully
- **And** the questionnaire has more than one associated prompt
- **When** the report-generation screen is shown
- **Then** the application MUST present the available outcomes to the user using the questionnaire's associated prompt metadata
- **And** it MUST allow the user to choose which outcome to generate

#### Scenario: Questionnaire has a single associated outcome
- **Given** a questionnaire has exactly one associated prompt
- **When** the report-generation flow starts
- **Then** the application MAY select that prompt automatically
- **And** it MUST use that associated `promptKey` for the AI request

### Requirement: Survey report generation MUST propagate the selected prompt key end-to-end.

The selected questionnaire prompt MUST be carried through survey submission and any direct clinical writer fallback request so the generated report matches the chosen outcome.

#### Scenario: Submit a survey response with a selected questionnaire prompt
- **Given** the user selected an available questionnaire outcome
- **When** the survey-based application submits the response and requests AI enrichment
- **Then** the system MUST use the selected associated `promptKey` instead of a hardcoded default survey key

#### Scenario: Questionnaire has no associated prompt yet
- **Given** a questionnaire has no configured prompt associations
- **When** the survey-based application requests AI report generation
- **Then** the system MUST preserve legacy behavior for backward compatibility

