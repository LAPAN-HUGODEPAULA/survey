# Prompt Editing Runbook (MongoDB)

This runbook describes how clinicians edit Clinical Writer prompt components stored in MongoDB.

## Scope
- Questionnaire-specific clinical logic is stored in the `QuestionnairePrompts` collection.
- Output tone, audience, and restrictions are stored in the `PersonaSkills` collection.
- For migrated survey flows, the Clinical Writer composes both documents at request time.
- Updates become effective on the next eligible request without a deploy or process restart.

## Safe Editing Workflow
1) Connect to the application MongoDB.
2) For questionnaire clinical logic, open the `QuestionnairePrompts` document that matches the target `promptKey`.
3) For tone or audience changes, open the `PersonaSkills` document that matches the target `personaSkillKey` or `outputProfile`.
4) Edit only the responsibility of that document:
   - `QuestionnairePrompts`: clinical interpretation rules for the questionnaire.
   - `PersonaSkills`: style, audience, tone, and output restrictions.
5) Keep the instructions compatible with JSON-only report generation.
6) Save the document. The next matching request will use the updated version.

## Guardrails
- Do not include PHI in prompts. Use placeholders when you need examples.
- Keep section headings and required fields consistent with ReportDocument schema.
- Avoid adding Markdown formatting tokens (e.g., ``` or **). The service expects JSON only.
- If a prompt change causes errors, revert the MongoDB document to the last good version.

## Verification
- Submit a representative request through `/process` or the survey flow that uses the edited questionnaire prompt or persona skill.
- Confirm the response includes updated `questionnaire_prompt_version` and `persona_skill_version` values.
- Confirm the response still matches the JSON schema expected by `ReportDocument`.
