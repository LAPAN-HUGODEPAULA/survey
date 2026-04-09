## Context

Survey-derived report generation currently resolves questionnaire prompt identity from the survey record, but persona selection still depends on request-level fields or hardcoded fallback mappings in `survey_prompt_selection.py`. At the same time, `survey-builder` already exposes survey editing and persona catalog management, but it cannot persist survey-level default persona behavior.

This change crosses backend models, OpenAPI, generated clients, Flutter survey editing, and runtime selection precedence. It must remain backward compatible for surveys that do not yet carry persona configuration, and it must keep request-level overrides authoritative.

## Goals / Non-Goals

**Goals:**

- Extend the survey schema with nullable default `personaSkillKey` and `outputProfile` fields.
- Let `survey-builder` configure and reload those defaults when creating or editing surveys.
- Update backend validation so survey-level persona configuration is coherent and references known persona skills.
- Change runtime selection precedence to use request overrides first, then survey defaults, then legacy hardcoded fallbacks.
- Return a clear configuration error when a survey points to an unknown or deleted persona skill instead of silently reverting to legacy behavior.

**Non-Goals:**

- Support multiple persona/output combinations on a single survey.
- Introduce governance workflows such as approvals, versioning, or rollback.
- Change questionnaire prompt ownership or prompt-association behavior.
- Replace request-level override behavior.

## Decisions

### 1. Store survey-level persona defaults as nullable top-level survey fields

The survey contract will add nullable `personaSkillKey` and `outputProfile` fields alongside the existing nullable `prompt` reference.

Why:

- These settings are survey defaults, not reusable prompt-catalog metadata.
- Top-level fields keep the contract simple for backend persistence and Flutter mappings.
- `null` preserves compatibility for existing survey documents.

Alternative considered:

- Nesting persona settings under a separate survey configuration object was rejected because it adds contract churn without providing clearer semantics for this small scope.

### 2. Treat `personaSkillKey` as the authoritative survey default and validate `outputProfile` against it

When a survey stores both fields, the backend should validate that the referenced persona skill exists and that its declared `outputProfile` matches the stored survey `outputProfile`. If only `personaSkillKey` is provided, the backend may derive the survey `outputProfile` from the matched persona skill for consistency in responses. If only `outputProfile` is provided, runtime resolution may still map it to a persona skill using the existing output-profile logic.

Why:

- `PersonaSkills` already provide a unique mapping from persona key to output profile.
- Validation avoids ambiguous or contradictory survey defaults.
- The explicit `outputProfile` field still supports the requested survey-level configuration and keeps the response model aligned with runtime request fields.

Alternative considered:

- Allowing the two fields to drift independently was rejected because conflicting defaults would make precedence and error handling opaque.

### 3. Runtime precedence becomes request override → survey default → legacy fallback

Selection logic will resolve persona-related settings in this order:

1. request-level `personaSkillKey` / `outputProfile`
2. survey-level default `personaSkillKey` / `outputProfile`
3. current hardcoded fallback maps

If a survey default `personaSkillKey` is configured but no longer resolves to an existing persona skill, the backend must raise a configuration error instead of silently falling back.

Why:

- It matches the user’s explicit acceptance criteria.
- It preserves current behavior for surveys with no persona configuration.
- It makes survey configuration a real default rather than a hint that can be bypassed by hidden fallback logic.

Alternative considered:

- Survey defaults overriding explicit request fields was rejected because request-level overrides are already part of the runtime contract and must remain the highest-precedence input.

### 4. Survey-builder should reuse the existing persona catalog for both controls

The survey editor will load persona skills from the existing catalog and use them to populate:

- a default persona skill selector
- a default output profile selector

The UI should keep the two controls consistent by reloading saved values and guiding the user toward valid combinations.

Why:

- It avoids introducing a second source of truth for output-profile options.
- It reuses the persona catalog already exposed in the admin UI.
- It reduces the chance of typing invalid values manually.

Alternative considered:

- Free-text fields were rejected because they would weaken validation and increase mismatch risk.

## Risks / Trade-offs

- [Survey defaults become inconsistent with the persona catalog after a persona is deleted] -> Reject runtime processing with a clear configuration error and surface the issue during survey editing when possible.
- [Persisting both `personaSkillKey` and `outputProfile` duplicates catalog data] -> Accept the duplication because it preserves explicit survey defaults and keeps the survey API aligned with runtime request concepts.
- [Generated client refresh may touch many files] -> Keep the proposal scoped to affected contract-backed models and verify the generated diff is intentional.
- [UI complexity increases in the survey form] -> Reuse existing survey-builder patterns and persona catalog data instead of adding a new configuration subsystem.

## Migration Plan

No destructive migration is required. Existing surveys continue to deserialize with `personaSkillKey: null` and `outputProfile: null` (or omitted fields) and will continue using current fallback behavior.

Deployment sequence:

1. Update backend models, persistence, validation, and selection logic.
2. Update OpenAPI and regenerate clients.
3. Update `survey-builder` mappings and form controls.
4. Verify older survey records without persona defaults still work unchanged.

Rollback can remove the new survey fields from the UI and runtime selection logic. Stored nullable fields in MongoDB can remain ignored if rollback is needed.

## Open Questions

None at proposal time. The intended precedence and backward-compatibility rules are explicit enough to implement.
