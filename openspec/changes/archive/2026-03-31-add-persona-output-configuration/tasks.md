## 1. Backend Survey Contract

- [x] 1.1 Extend the survey domain model, repository, and survey CRUD routes to accept and return nullable survey-level `personaSkillKey` and `outputProfile` fields.
- [x] 1.2 Add backend validation so survey persona defaults remain backward compatible when absent, but reject unknown or inconsistent persona configuration with a clear error.
- [x] 1.3 Update `packages/contracts/survey-backend.openapi.yaml` to describe the new survey-level persona configuration fields and regenerate affected clients.

## 2. Runtime Selection Logic

- [x] 2.1 Update survey prompt/persona resolution helpers so request-level overrides take precedence over survey defaults, and survey defaults take precedence over legacy hardcoded fallbacks.
- [x] 2.2 Return a clear configuration error when survey-level `personaSkillKey` references an unknown or deleted persona skill and no request-level override is present.
- [x] 2.3 Add backend tests covering selection precedence, backward compatibility for surveys without persona configuration, and failure behavior for stale persona references.

## 3. Survey-Builder

- [x] 3.1 Update Flutter survey models and mappings to read and write nullable survey-level `personaSkillKey` and `outputProfile` values.
- [x] 3.2 Add survey-builder form controls for choosing default persona skill and default output profile, reusing the persona catalog and preserving stored values when editing.
- [x] 3.3 Add UI tests for survey create/read/update flows with and without persona defaults, then run `flutter analyze` for `apps/survey-builder`.
