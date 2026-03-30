# Tasks: Refactor Clinical Writer Prompt Storage

## 1. Specification and Contract

- [x] 1.1. Update the Clinical Writer prompt-resolution contract so survey-derived requests resolve questionnaire logic and persona skill independently.
- [x] 1.2. Define the `QuestionnairePrompts` storage contract, including stable key, non-empty instructions, and separation from persona concerns.
- [x] 1.3. Define the `PersonaSkills` storage contract, including stable key, output-profile binding, and editable style/restriction instructions.
- [x] 1.4. Define the survey report flow contract for carrying questionnaire prompt identity and persona skill identity end to end.

## 2. Backend and Clinical Writer Implementation

- [x] 2.1. Update `services/clinical-writer-api` to load migrated prompt components from MongoDB and compose the effective runtime prompt without using hardcoded LangGraph prompts as the primary source.
- [x] 2.2. Add repository or adapter support for `QuestionnairePrompts` and `PersonaSkills` in the backend systems that manage prompt data.
- [x] 2.3. Update request/response models, worker payload construction, and any routing logic needed to propagate persona skill selection separately from questionnaire prompt selection.
- [x] 2.4. Preserve a controlled fallback path for non-migrated prompt flows until the migration is complete.

## 3. Migration and Data Seeding

- [x] 3.1. Add migration scripts that create `QuestionnairePrompts` and `PersonaSkills`.
- [x] 3.2. Backfill questionnaire-level prompt logic from current Mongo-backed prompt documents and any remaining hardcoded survey prompt sources.
- [x] 3.3. Seed persona skill documents for the currently supported output profiles, including the school-report profile.
- [x] 3.4. Verify that migrated survey flows can resolve both components without requiring new deploys after prompt edits.

## 4. Validation and Documentation

- [x] 4.1. Add or update unit tests for prompt composition, fallback behavior, and version traceability in `services/clinical-writer-api`.
- [x] 4.2. Add or update integration tests for survey-worker/backend propagation of questionnaire prompt and persona skill identifiers.
- [x] 4.3. Run `uv run python -m compileall services/survey-backend/app` and relevant Clinical Writer test commands after implementation.
- [x] 4.4. Update runbooks and architecture docs to replace Google Drive editing guidance with MongoDB-backed editing guidance for migrated flows.
- [x] 4.5. Regenerate any affected API clients if backend contracts change and verify the resulting diff is intentional.
