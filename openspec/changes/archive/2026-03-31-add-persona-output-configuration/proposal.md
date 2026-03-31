## Why

Survey-driven report generation still relies on request-level persona fields or hardcoded runtime defaults, which makes persona behavior harder to reason about and configure per questionnaire. Persisting explicit survey-level persona defaults lets administrators control the expected report persona in the same place they configure the survey itself while preserving legacy behavior for surveys that have not been updated yet.

## What Changes

- Extend the survey contract to support nullable default `personaSkillKey` and `outputProfile` configuration on each survey.
- Update `survey-builder` so administrators can select and persist a default persona skill and default output profile while editing a survey.
- Update backend survey validation, persistence, and API responses to accept and return survey-level persona configuration without breaking existing surveys.
- Update survey response selection precedence so request-level `personaSkillKey` and `outputProfile` still win, but survey defaults are used before legacy hardcoded fallbacks.
- Return a clear configuration error when a survey references an unknown or deleted persona skill instead of silently falling back.
- Regenerate affected API clients and update Flutter mappings that consume the survey contract.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `backend-survey-management`: extend survey create/read/update behavior to persist nullable default persona configuration and validate referenced persona skills.
- `frontend-survey-builder`: extend the survey editor to configure, save, and reload survey-level default persona skill and output profile values.
- `survey-report-prompt-selection`: change runtime precedence so request overrides remain first, survey defaults are second, and legacy hardcoded defaults are used only when no survey persona configuration exists.

## Impact

- Affected systems:
  - `services/survey-backend`
  - `apps/survey-builder`
  - `packages/contracts/survey-backend.openapi.yaml`
  - `packages/contracts/generated/dart`
- Affected runtime paths:
  - survey CRUD endpoints under `/api/v1/surveys`
  - survey-derived persona and output-profile resolution in backend selection helpers
  - Flutter survey create/edit mappings and generated client models
- Backward compatibility requirements:
  - existing surveys with no persona configuration must continue to work with current fallback behavior
  - request-level `personaSkillKey` and `outputProfile` must continue to override survey defaults
