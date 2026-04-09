# Change: Add Survey Builder Application

## Why

The current multi-prompt model introduces complexity without product value:

- It allows questionnaires to store more than one prompt even though the questionnaire flow now needs only one AI prompt.
- It requires prompt-type metadata and outcome-selection behavior that are no longer needed.
- It makes the API and UI harder to reason about because clients must handle prompt ordering, multiplicity, and validation rules that no longer reflect the intended behavior.

Using a single nullable prompt reference keeps the survey contract aligned with the actual product flow:

- A survey may have no AI prompt configured yet.
- A survey may reference exactly one reusable prompt when AI generation is desired.
- Report-generation flows can resolve that prompt automatically without prompting the user to choose an outcome.

## What Changes

- Create the `survey-builder` Flutter application for survey CRUD workflows.
- Extend `survey-backend` with survey management endpoints and the supporting contract updates.
- Replace survey `promptAssociations` with a single nullable `prompt` reference.
- Remove `outcomeType` from reusable survey prompt definitions and questionnaire configuration.
- Update report-generation flows so they automatically use the configured questionnaire prompt when present.
- Regenerate the Dart client to match the updated survey and prompt contracts.

## Impact

- Affected specs:
  - `backend-survey-management`
  - `frontend-survey-builder`
  - `survey-prompt-management`
  - `survey-report-prompt-selection`
- Affected systems:
  - `apps/survey-builder`
  - `services/survey-backend`
  - `packages/contracts/survey-backend.openapi.yaml`
  - `packages/contracts/generated/dart`
