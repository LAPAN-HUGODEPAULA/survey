# Change: Refactor Clinical Writer Prompt Storage into QuestionnairePrompts and PersonaSkills

## Why

The current Clinical Writer prompt model still mixes responsibilities:

- Questionnaire-specific clinical reasoning is coupled to stylistic output rules in a single prompt surface.
- Part of the runtime behavior still depends on hardcoded LangGraph fallbacks and legacy provider assumptions.
- A clinician cannot safely change the tone or constraints of a report profile by editing MongoDB alone and expecting the next request to use the new version without a deploy.

Separating prompt storage into `QuestionnairePrompts` and `PersonaSkills` makes the runtime model explicit:

- `QuestionnairePrompts` owns the clinical logic that belongs to a questionnaire.
- `PersonaSkills` owns the tone, style, audience, and restrictions that belong to an output profile.
- `clinical-writer-api` composes both documents at request time, so MongoDB edits become the operational control plane instead of code deploys.

## What Changes

- Introduce a MongoDB `QuestionnairePrompts` collection for questionnaire-specific clinical instructions.
- Introduce a MongoDB `PersonaSkills` collection for output-profile style and restriction instructions.
- Update Clinical Writer prompt resolution so survey-derived requests compose runtime prompts from both collections instead of relying on hardcoded LangGraph prompt text as the primary source.
- Define end-to-end propagation of questionnaire prompt identity and persona skill identity for survey-based report generation.
- Add migration requirements to create, seed, and backfill the new collections while preserving a controlled fallback path for unmigrated flows.
- Update runbooks and technical documentation so prompt editing is performed through MongoDB-backed documents instead of Google Drive documents for migrated flows.

## Impact

- Affected specs:
  - `clinical-writer-prompt-resolution`
  - `survey-prompt-management`
  - `survey-report-prompt-selection`
  - `database-migration`
  - `persona-skill-management` (new)
- Affected systems:
  - `services/clinical-writer-api`
  - `services/survey-backend`
  - `services/survey-worker`
  - `tools/migrations/`
  - `docs/runbooks/prompt-editing.md`
  - `docs/software-design.md`
  - `docs/technical-specification.md`
