# Design: Survey AI Prompt Management

## 1. Architectural Approach

This change introduces questionnaire-scoped AI prompt configuration without moving prompt lookup logic into frontend applications.

### 1.1 Decision: keep prompt catalog management behind `survey-backend`

The `survey-builder` will manage prompts through backend APIs rather than direct MongoDB access.

Rationale:

- Frontend applications must not embed database credentials or implement database access logic.
- Prompt validation, uniqueness checks, and usage constraints belong in a backend boundary.
- The existing project already uses `survey-backend` as the contract owner for survey administration.

### 1.2 Decision: let `clinical-writer-api` resolve prompt text from MongoDB

Survey-based apps and `survey-backend` will continue sending a `prompt_key`, but `clinical-writer-api` will become responsible for loading the prompt body from MongoDB for survey-driven keys.

Rationale:

- The clinical writer service already owns prompt resolution through `PromptRegistry`.
- Keeping resolution inside `clinical-writer-api` preserves a single source of truth for prompt loading and `prompt_version` generation.
- This minimizes coupling between `survey-backend` and prompt storage details.

### 1.3 Decision: preserve Google Drive and local fallback providers

Mongo-backed prompt lookup will be the primary path for survey prompts. If a key is not present in MongoDB, `clinical-writer-api` will continue through the existing fallback chain so `clinical-narrative` and any non-migrated prompt keys remain functional.

Rationale:

- The requested scope explicitly excludes `clinical-narrative`.
- A staged migration avoids forcing all prompt consumers onto the new storage model at once.

## 2. Data Model

### 2.1 Prompt catalog record

Each reusable survey prompt record should contain:

- `promptKey`: stable code identifier used at runtime.
- `name`: human-readable name shown in the builder UI.
- `outcomeType`: one of the five supported outcome types.
- `promptText`: the stored instruction text.
- Audit metadata such as creation and modification timestamps.

`promptKey` must be unique and code-safe. The implementation should prefer a composed key that makes the survey intent obvious, for example `clinical_referral_letter:lapan7`, while still treating the stored key as the runtime identifier.

### 2.2 Survey prompt associations

Survey definitions should embed a compact list of associated prompt references. Each association should include enough data for client rendering and runtime selection:

- `promptKey`
- `name`
- `outcomeType`

The association list must allow one prompt per outcome type for a given survey. This keeps report selection deterministic and prevents ambiguous routing.

## 3. User Experience

### 3.1 `survey-builder`

The builder will gain two related capabilities:

- A prompt catalog management area for reusable prompts.
- Prompt association controls inside the questionnaire form so the editor can attach outcome prompts to the survey being created or edited.

The survey form should validate duplicate outcome types before save.

### 3.2 `survey-frontend` and `survey-patient`

Both survey-based reporting flows currently render a single report result. After this change:

- If a questionnaire has one associated prompt, the existing automatic report generation can continue with that prompt.
- If a questionnaire has multiple associated prompts, the app must let the user choose which outcome to generate before invoking the AI flow.
- If a questionnaire has no associated prompt yet, the flow should remain backward-compatible by falling back to the existing legacy behavior.

This keeps current surveys working while enabling richer outcome generation for migrated questionnaires.

## 4. Service Behavior

### 4.1 `survey-backend`

`survey-backend` remains the contract owner for:

- Prompt catalog CRUD.
- Survey CRUD including prompt associations.
- Passing the selected `prompt_key` through survey response creation and any direct clinical writer proxy calls used by survey apps.

### 4.2 `clinical-writer-api`

`clinical-writer-api` will extend `PromptRegistry` to support Mongo-backed prompt lookup before existing fallback providers.

Prompt versioning for Mongo-backed prompts should be derived from database metadata, such as the last modification timestamp or an explicit version field, so responses continue returning a traceable `prompt_version`.

## 5. Compatibility and Migration

- Existing surveys without prompt associations remain valid.
- Existing hardcoded survey keys such as `survey7` continue to work through fallback behavior until migrated.
- `clinical-narrative` remains unchanged and can continue using Google Drive-backed prompts.

## 6. Risks and Mitigations

### 6.1 Risk: prompt deletion creates broken survey associations

Mitigation:

- The prompt catalog must reject deletion when a prompt is still associated with any survey, or require the associations to be removed first.

### 6.2 Risk: duplicate outcome mappings per survey

Mitigation:

- Enforce one prompt per outcome type in backend validation and in the builder UI.

### 6.3 Risk: report generation regressions during migration

Mitigation:

- Preserve the current fallback path when Mongo lookup does not find a prompt key.
