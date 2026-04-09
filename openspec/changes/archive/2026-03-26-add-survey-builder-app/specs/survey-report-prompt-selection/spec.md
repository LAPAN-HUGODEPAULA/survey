# Spec: Survey Report Prompt Selection

This spec updates survey-driven report generation for the single nullable questionnaire prompt model.

## MODIFIED Requirements

### Requirement: Survey-based report flows MUST use the questionnaire's configured prompt when present.

The `survey-frontend` and `survey-patient` applications MUST use the questionnaire's stored nullable `prompt` reference to determine whether a survey submission should use a reusable AI prompt.

This is required because questionnaires no longer expose multiple prompt outcomes. The runtime must either use the one configured prompt automatically or fall back to legacy behavior when no prompt is configured.

#### Scenario: Questionnaire has a configured prompt
- **Given** a survey response has been submitted successfully
- **And** the questionnaire has a non-null `prompt` reference
- **When** the report-generation flow starts
- **Then** the application MUST use that configured `promptKey`
- **And** it MUST NOT ask the user to choose an outcome or prompt type

#### Scenario: Questionnaire has no configured prompt
- **Given** a questionnaire has `prompt: null`
- **When** the survey-based application requests AI report generation
- **Then** the system MUST preserve legacy behavior for backward compatibility

### Requirement: Survey report generation MUST propagate the configured questionnaire prompt key end-to-end.

When a questionnaire has a configured prompt, that `promptKey` MUST be carried through survey submission and any direct clinical writer fallback request so the generated report matches the survey's configured reusable prompt.

#### Scenario: Submit a survey response with a configured questionnaire prompt
- **Given** the questionnaire has a configured reusable prompt
- **When** the survey-based application submits the response and requests AI enrichment
- **Then** the system MUST use the questionnaire's configured `promptKey` instead of a hardcoded default survey key
