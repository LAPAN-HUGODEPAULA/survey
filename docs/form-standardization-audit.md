# Form Standardization Audit

Change: `cr-ux-003-form-standardization`  
Review baseline: after `cr-ux-001-standardize-feedback-severity-icons-and-message-structure` and `cr-ux-002-secure-entry-standards`

## Shared Components Extended

- `DsValidationSummary`
  Canonical form-level summary for multiple validation issues, with optional labeled items and navigation callbacks.
- `DsSection`
  Canonical section container for grouped form content and long-form wayfinding.
- `DsFieldChrome`
  Canonical label/supporting/error wrapper used by custom field surfaces such as the HTML editor.
- `DsValidatedTextFormField`
  Shared delayed-validation text field for structured forms.
- `DsValidatedDropdownButtonFormField`
  Shared delayed-validation dropdown field for structured forms.
- `DsFormFormatters`
  Shared input formatter and normalization helpers for CPF, CEP, phone, and Brazilian date input.
- `DsPatientIdentitySection`
  Shared identity form surface migrated to delayed validation and shared date formatting.
- `DsSurveyDemographicsSection`
  Shared demographics surface migrated to delayed validation, grouped inline feedback, and shared field behavior.

## Pilot Forms Included

- `apps/survey-patient/lib/features/demographics/pages/demographics_page.dart`
- `apps/survey-frontend/lib/features/demographics/pages/demographics_page.dart`
- `apps/clinical-narrative/lib/features/demographics/pages/demographics_page.dart`
- `apps/survey-builder/lib/features/survey/pages/survey_form_page.dart`

## Explicitly Out Of Scope

- Freeform chat composer inputs in `clinical-narrative`
- A new masking dependency such as `mask_text_input_formatter`
- Rewriting every form in every app during this change
