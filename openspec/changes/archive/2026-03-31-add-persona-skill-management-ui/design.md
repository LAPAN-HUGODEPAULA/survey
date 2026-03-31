## Context

`survey-builder` already provides CRUD flows for surveys and reusable survey prompts, but persona skills remain operationally managed outside the app even though `survey-backend` already exposes `/api/v1/persona_skills` endpoints. The new UI must fit the existing survey administration flow, reuse the shared Flutter design system, and avoid any changes to survey payloads, survey schema, or Clinical Writer runtime selection behavior.

The current backend already enforces the core data rules for persona skills:

- required `personaSkillKey`, `name`, `outputProfile`, and `instructions`
- normalized lowercase key fields with `^[a-z0-9:_-]+$`-style constraints
- unique `personaSkillKey`
- unique `outputProfile`

## Goals / Non-Goals

**Goals:**

- Add a dedicated persona skill catalog entry point from the main `survey-builder` screen.
- Provide list, create, edit, and delete flows for persona skills using the existing backend endpoints.
- Match backend validation rules in the Flutter form so most invalid submissions are blocked before the request.
- Surface duplicate `personaSkillKey` and `outputProfile` conflicts clearly in the UI while keeping the backend as the source of truth.
- Reuse existing `survey-builder` patterns for repositories, navigation, dialogs, loading states, and form layout.

**Non-Goals:**

- Assign persona skills to surveys.
- Change survey create or update payloads.
- Change runtime persona resolution or Clinical Writer selection logic.
- Add version history, approvals, rollback, or diff-review workflows for persona skills.

## Decisions

### 1. Add persona skill management as a sibling flow to reusable prompt management

The survey list screen will expose a new top-level navigation action for persona skills, parallel to the existing reusable prompt catalog.

Why:

- It keeps persona skill administration inside the current survey admin entry point.
- It matches how administrators already access reusable prompt CRUD.
- It avoids coupling persona skill management to survey editing, which is explicitly out of scope.

Alternative considered:

- Embedding persona skills inside the survey form was rejected because persona skills are a global catalog and the proposal explicitly avoids survey-assignment work.

### 2. Follow the existing Flutter CRUD pattern instead of introducing a new state-management approach

Implementation will mirror the existing reusable prompt flow:

- a lightweight draft model for persona skills
- a repository backed by `Dio` and `ApiConfig`
- a list page for loading and deleting
- a form page for create and edit

Why:

- This keeps the change small and consistent with the current app.
- It reduces implementation risk by reusing a proven page structure, confirmation pattern, and error-handling approach.

Alternative considered:

- Adopting generated API clients or a new state-management library was rejected because the current app already uses simple repository wrappers and the change does not require a broader architecture shift.

### 3. Match backend validation rules in the form and use catalog-aware duplicate checks for clearer errors

The form will enforce:

- required `personaSkillKey`, `name`, `outputProfile`, and `instructions`
- lowercase key formatting for `personaSkillKey` and `outputProfile`
- allowed characters limited to letters, digits, colon, underscore, and hyphen

Before submit, the UI will compare the edited values against the currently loaded catalog to detect duplicate `personaSkillKey` and duplicate `outputProfile` conditions and show field-level validation errors. The backend remains authoritative, so any write failure returned by the API will still be surfaced after submit.

Why:

- It aligns the user experience with current backend rules.
- It gives clearer feedback than a generic server failure for the common duplicate cases.
- It avoids requiring new endpoints or schema changes.

Alternative considered:

- Relying only on backend conflict responses was rejected because the current API shape is sufficient for CRUD but does not guarantee field-specific conflict messages for every duplicate case.

### 4. Keep edit semantics aligned with the existing API contract

Editing will continue to use `PUT /persona_skills/{personaSkillKey}` with the same key in the path and body. To avoid accidental key renames through a replace-style update, the form will treat `personaSkillKey` as read-only in edit mode, matching the current reusable prompt flow.

Why:

- It matches the established admin pattern already used in `survey-builder`.
- It avoids unnecessary complexity around key renames, which are not part of the requested scope.

Alternative considered:

- Supporting persona key renames was rejected because it would need additional conflict handling and could blur the boundary between editing a record and replacing an operational identifier.

### 5. No migration or contract regeneration work is required

The change reuses an already implemented backend API and does not alter OpenAPI schemas, survey contracts, or runtime behavior.

Why:

- The requested scope is a frontend management surface over existing capabilities.
- Avoiding contract churn keeps the proposal aligned with the stated non-goals.

## Risks / Trade-offs

- [Catalog data becomes stale during a long editing session] -> Reload the catalog when returning from create or edit flows and continue treating backend responses as authoritative on save.
- [Client-side duplicate checks cannot eliminate race conditions] -> Preserve backend conflict handling and show the returned failure when concurrent changes slip past local validation.
- [Adding more top-level admin actions could clutter the survey list screen] -> Reuse the existing action group styling and keep persona skill entry as a dedicated catalog action rather than embedding extra controls into survey rows.
- [Read-only keys may frustrate administrators who want to rename operational identifiers] -> Keep the current stable-key model explicit and leave any future rename workflow for a separate proposal.

## Migration Plan

No data migration is required. Deployment is limited to shipping the new `survey-builder` pages and wiring them into the existing navigation flow.

Rollback is straightforward: remove the new navigation entry and pages from the frontend. Existing backend behavior and stored persona skill documents remain unchanged.

## Open Questions

None at proposal time. The scope is bounded by the existing API and the stated non-goals.
