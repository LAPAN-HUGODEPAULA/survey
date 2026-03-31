## Why

Administrators can already manage persona skills through the backend API, but the survey administration workflow still lacks a supported UI for that catalog. This forces operational changes to persona instructions outside the product and makes routine maintenance harder than reusable prompt management.

## What Changes

- Add a dedicated persona skill catalog screen to `survey-builder`, reachable from the main survey administration flow.
- Allow administrators to list persona skills from `GET /persona_skills/`.
- Allow administrators to create, edit, and delete persona skills using the existing `/api/v1/persona_skills` endpoints.
- Add form validation and error handling in the UI for required fields, backend key-format rules, duplicate `personaSkillKey`, and duplicate `outputProfile`.
- Reuse existing Flutter design-system components and current `survey-builder` navigation and CRUD patterns.
- Keep survey payloads, survey schema, report selection behavior, and Clinical Writer runtime selection logic unchanged.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `persona-skill-management`: clarify administrator-facing CRUD expectations, including delete support and uniqueness constraints relevant to UI management.
- `frontend-survey-builder`: add persona skill catalog navigation, CRUD screens, validation, and backend error surfacing in the survey-builder app.

## Impact

- Affected systems:
  - `apps/survey-builder`
  - `packages/design_system_flutter`
- Reused APIs:
  - `GET /api/v1/persona_skills/`
  - `POST /api/v1/persona_skills/`
  - `PUT /api/v1/persona_skills/{personaSkillKey}`
  - `DELETE /api/v1/persona_skills/{personaSkillKey}`
- No changes to:
  - survey create or update payloads
  - survey schema
  - Clinical Writer runtime persona selection behavior
