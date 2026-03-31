## Why

The post-survey experience in `survey-patient` is too sparse: the thank-you screen keeps the agent results behind a modal button and the radar only shows `Q1`, `Q2`, etc., which makes the insights hard to read. While patients already send responses, there is no quick way to restart the flow for another respondent.

## What Changes

- Replace the thank-you layout with a modern “Avaliação preliminar” card that fetches the agent result inline (with loading + error states), a colorful radar chart keyed by question labels, the existing “Adicionar informações” workflow, and a new “Iniciar nova avaliação” action that clears app state and returns to the public landing screen.
- Modernize the radar visualization so it uses the newly added question labels (falling back to legacy numbering) and a more engaging color palette; the radar should highlight each question’s label inside the chart or legend rather than cryptic identifiers.
- Extend the survey schema, migrations, and APIs to persist an optional `label` per question, auto-populate it for legacy questions with a descriptive phrase (“Luzes pulsantes”, etc.), and expose it wherever surveys are listed or previewed.
- Update `survey-builder` so authors can edit these labels (with previews showing them), and ensure the label is returned when editing or exporting a questionnaire.

## Capabilities

### New Capabilities
- `patient-assessment-summary`: Defines the thank-you/assessment screen layout for `survey-patient`, the inline agent feedback, “Avaliação preliminar” messaging, radar styling, and the “Iniciar nova avaliação” flow.
- `survey-question-labels`: Covers the question-level `label` metadata, database migration, API surface, builder UX, fallback behavior, and reuse opportunities for future agents.

### Modified Capabilities
- `patient-survey-flow`: Update the thank-you screen requirement to reference the new assessment summary layout and remove the standalone “Get Results” flow.
- `backend-survey-management`: Require survey payloads to optionally accept a `label` per question (returned on read) and describe the legacy migration.
- `frontend-survey-builder`: Add requirements for showing/editing question labels inside the builder and surfacing them in listings/previews.

## Impact

- `survey-patient`: UI/UX for thank-you screen, radar component, state reset, agent integration, and navigation.
- Backend services handling survey definitions and migrations (MongoDB schema + API payloads).
- `survey-builder`: Editors, lists, previews, and API calls now include `label`; migrations must pre-fill the field for existing questionnaires.
