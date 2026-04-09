# Prompt Editing Runbook

This runbook describes how clinicians edit Clinical Writer prompt components used by migrated survey flows.

## Scope

- Questionnaire-specific clinical logic is stored in the `QuestionnairePrompts` collection.
- Output tone, audience, and restrictions are stored in the `PersonaSkills` collection.
- For migrated survey flows, the Clinical Writer composes both documents at request time.
- Updates become effective on the next eligible request without a deploy or process restart.
- The preferred editing surface is the `survey-builder` app, which now exposes both questionnaire prompt and persona skill catalogs.
- `survey-builder` survey editing also lets administrators persist default `personaSkillKey` and `outputProfile` values on each survey.
- Direct MongoDB editing remains an operational fallback when the UI is unavailable or when recovery work requires it.

## Safe Editing Workflow

1) Prefer the `survey-builder` admin flow for routine changes:
   - use the reusable prompt catalog for `QuestionnairePrompts`
   - use the persona catalog for `PersonaSkills`
   - update the survey record itself when a persona change should apply only as that survey's default
2) If the UI is unavailable or a recovery task requires direct access, connect to the application MongoDB.
3) For questionnaire clinical logic, open the `QuestionnairePrompts` document that matches the target `promptKey`.
4) For tone or audience changes, open the `PersonaSkills` document that matches the target `personaSkillKey` or `outputProfile`.
5) Edit only the responsibility of that document:
   - `QuestionnairePrompts`: clinical interpretation rules for the questionnaire.
   - `PersonaSkills`: style, audience, tone, and output restrictions.
6) Keep the instructions compatible with JSON-only report generation.
7) Save the change. The next matching request will use the updated version.
8) If the change is survey-specific, reopen the survey in `survey-builder` and confirm the intended default `personaSkillKey` and `outputProfile` are selected.

## Guardrails

- Do not include PHI in prompts. Use placeholders when you need examples.
- Keep section headings and required fields consistent with ReportDocument schema.
- Avoid adding Markdown formatting tokens (e.g., ``` or **). The service expects JSON only.
- If a prompt change causes errors, revert the MongoDB document to the last good version.

## Verification

- Submit a representative request through `/process` or the survey flow that uses the edited questionnaire prompt or persona skill.
- Confirm the response includes updated `questionnaire_prompt_version` and `persona_skill_version` values.
- Confirm the response still matches the JSON schema expected by `ReportDocument`.
