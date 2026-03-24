# Change: Add Survey AI Prompt Management

## Why

Survey-driven AI reports currently depend on prompt documents loaded from Google Drive. That makes questionnaire-specific prompt management difficult, prevents the `survey-builder` from owning prompt configuration, and does not support multiple report outcomes per questionnaire in a structured way.

The platform now needs reusable prompts stored in MongoDB, explicit prompt associations on each questionnaire, and a way for survey-based applications to request different report outcomes such as referral letters or parental guidance while keeping `clinical-narrative` on its current Google Drive flow.

## What Changes

- Add a reusable survey prompt catalog stored in MongoDB and managed through `survey-backend` APIs consumed by `survey-builder`.
- Define five supported survey prompt outcome types:
  - `patient_condition_overview`
  - `clinical_diagnostic_report`
  - `clinical_referral_letter`
  - `parental_guidance`
  - `educational_support_summary`
- Extend survey definitions so each questionnaire can associate one or more prompts, with at most one prompt per outcome type.
- Update `survey-builder` so users can create, edit, delete, and associate reusable prompts while editing a questionnaire.
- Update `survey-frontend` and `survey-patient` so report-generation flows use the questionnaire’s associated prompts and let the user choose among available outcomes when more than one is configured.
- Update `clinical-writer-api` so prompt resolution checks MongoDB first by `prompt_key`, then falls back to the existing Google Drive/local providers for non-migrated flows such as `clinical-narrative`.

## Impact

- Affected specs:
  - `backend-survey-management`
  - `frontend-survey-builder`
  - `survey-prompt-management`
  - `survey-report-prompt-selection`
  - `clinical-writer-prompt-resolution`
- Affected code:
  - `services/survey-backend/app/**`
  - `services/clinical-writer-api/clinical_writer_agent/**`
  - `apps/survey-builder/**`
  - `apps/survey-frontend/**`
  - `apps/survey-patient/**`
  - `packages/contracts/survey-backend.openapi.yaml`
  - `packages/contracts/generated/dart/**`
