## 1. Persona Skill Data Flow

- [x] 1.1 Add a persona skill draft model and repository in `apps/survey-builder` that wrap the existing `/api/v1/persona_skills` list, create, update, and delete endpoints.
- [x] 1.2 Implement repository error handling and form helpers so `personaSkillKey` and `outputProfile` follow backend-required trimming, lowercasing, required-field, and allowed-character rules.
- [x] 1.3 Add duplicate-detection support in the frontend flow so create and edit forms can surface conflicting `personaSkillKey` and `outputProfile` values clearly before or after save attempts.

## 2. Survey-Builder UI

- [x] 2.1 Add a dedicated persona skill catalog page in `apps/survey-builder` that lists persona skills from `GET /persona_skills/` using existing loading, empty, retry, and delete-confirmation patterns.
- [x] 2.2 Add a persona skill create and edit form page with fields for `personaSkillKey`, `name`, `outputProfile`, and `instructions`, reusing shared design-system components and the existing CRUD page layout.
- [x] 2.3 Wire the main survey administration screen to the new persona skill catalog so it is reachable as a top-level action alongside the existing admin flows.
- [x] 2.4 Ensure successful create, edit, and delete actions return users to a refreshed catalog and that backend failures are surfaced with actionable feedback.

## 3. Verification

- [x] 3.1 Add or update widget and repository tests covering persona skill listing, create, edit, delete, required-field validation, invalid key formats, and duplicate conflict feedback.
- [x] 3.2 Run `flutter analyze` in `apps/survey-builder` and fix any issues introduced by the change.
