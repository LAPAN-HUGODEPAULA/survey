# Tasks: Add Survey AI Prompt Management

## 1. Contracts and Domain Models

- [x] 1.1 Update `packages/contracts/survey-backend.openapi.yaml` to define survey prompt catalog endpoints and extend survey payloads with prompt associations.
- [x] 1.2 Regenerate Dart API clients with `tools/scripts/generate_clients.sh` and verify the generated contract diff is clean and intentional.
- [x] 1.3 Add or extend backend domain models for prompt records, prompt associations, and any request models needed for report outcome selection.

## 2. Survey Prompt Catalog in `survey-backend`

- [x] 2.1 Implement Mongo-backed repositories for reusable survey prompts.
- [x] 2.2 Add CRUD endpoints in `survey-backend` for listing, creating, updating, and deleting reusable prompts.
- [x] 2.3 Extend survey CRUD validation so surveys can persist prompt associations and reject duplicate outcome types or unknown prompt keys.
- [x] 2.4 Ensure survey response creation flows (`survey_responses` and `patient_responses`) propagate the selected prompt key instead of always hardcoding `survey7`, while preserving legacy fallback for surveys without configured prompt associations.

## 3. `survey-builder` UX

- [x] 3.1 Add UI to list and manage reusable prompts in the builder application.
- [x] 3.2 Extend the survey form to associate one prompt per outcome type to a questionnaire.
- [x] 3.3 Add validation and user feedback for duplicate outcome types, missing prompt associations, and deletion of prompts that are still in use.

## 4. Survey Report Generation UX

- [x] 4.1 Update `survey-frontend` to load associated survey prompt metadata and let the user select the desired report outcome when multiple prompts are configured.
- [x] 4.2 Update `survey-patient` with the same outcome-selection behavior.
- [x] 4.3 Ensure direct report-generation requests and response-submission flows send the selected `prompt_key`.

## 5. `clinical-writer-api` Prompt Resolution

- [x] 5.1 Add Mongo-backed prompt lookup to `clinical-writer-api` and make it the primary provider for survey prompt keys.
- [x] 5.2 Preserve Google Drive and local fallback providers when Mongo lookup does not resolve a key.
- [x] 5.3 Return traceable `prompt_version` metadata for Mongo-backed prompts.

## 6. Validation

- [x] 6.1 Run backend validation for touched Python modules with `uv run python -m compileall services/survey-backend/app` and the relevant `clinical-writer-api` test/validation commands.
- [x] 6.2 Run Flutter validation for `apps/survey-builder`, `apps/survey-frontend`, and `apps/survey-patient` with `flutter analyze`.
- [x] 6.3 Run `openspec validate add-survey-ai-prompts --strict`.
