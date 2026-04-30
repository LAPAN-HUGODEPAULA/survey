## Why

The screener flow in `survey-frontend` has friction points that slow down daily screenings: no default questionnaire (screeners must manually select one every session), inconsistent UI between apps, broken medication autocomplete due to per-keystroke API calls, missing scroll in the instructions page, and no access to AI-generated preliminary assessments or report generation from the thank-you page. This change aligns the screener flow with the polished patient flow and adds clinical document generation capabilities.

## What Changes

- **Default questionnaire**: Admin can set a default screener questionnaire via `survey-builder`; `survey-frontend` loads it at startup; the "Sessão profissional ativa" section displays the active questionnaire name.
- **Stepper UI parity**: `AssessmentFlowStepper` in `survey-frontend` adopts the same visual design as `PatientJourneyStepper` in `survey-patient`.
- **Centralized page titles**: All screener pages display a centered title in the `AppBar` (e.g., `demographics_page.dart` → "Avaliação do paciente").
- **Medication autocomplete fix**: Replace per-keystroke API calls with a single load-all-then-filter-in-memory approach; new medications are stored in memory first and persisted asynchronously on field blur.
- **Instructions page scroll fix**: Share the instructions page implementation from `survey-patient` (which already scrolls correctly) instead of maintaining a separate broken copy in `survey-frontend`.
- **Thank-you page cleanup**: Remove colored question labels from "Radar das respostas" and completely remove "Resumo das respostas" section.
- **Preliminary assessment (Avaliação preliminar)**: Add an AI-generated preliminary assessment section to the thank-you page in `survey-frontend`, using the existing access point "Análise automática do questionário profissional" with the default survey prompt ("Triagem de pacientes") and `patient_condition_overview` persona.
- **Report generation button**: Add a "Gerar Relatório" button on the thank-you page that navigates to a new `report_page.dart`.
- **New access points**: Create "Relatório clínico detalhado do paciente" (full_intake prompt + clinical_diagnostic_report persona), "Geração de carta de encaminhamento clínico", "Geração de carta de encaminhamento escolar", and "Geração de carta de orientação aos pais".
- **Screener report page**: New `report_page.dart` with buttons for email PDF delivery, clinical referral letter, school referral letter, and parent orientation letter.

## Capabilities

### New Capabilities
- `screener-default-questionnaire`: Admin-configurable default questionnaire for screener sessions, stored in database and loaded at startup
- `screener-stepper-parity`: Unified stepper component shared between survey-frontend and survey-patient
- `screener-thank-you-page`: Thank-you page with preliminary AI assessment, radar chart, and report generation for screener flow
- `screener-report-page`: Report page in survey-frontend with email delivery and clinical document generation buttons
- `screener-clinical-documents`: New access points for clinical referral letters (clinical, school, parent orientation) and detailed patient report
- `screener-instructions-page`: Shared instructions page component between survey-frontend and survey-patient

### Modified Capabilities
- `medication-autocomplete-component`: Change from per-keystroke API to load-all + in-memory filtering; add async persistence on field blur for new medications
- `thank-you-page-actions`: Extend to include "Gerar Relatório" button in survey-frontend (currently only in survey-patient)

## Impact

- **survey-frontend**: Stepper UI, page titles, instructions page, thank-you page, medication autocomplete, new report page
- **survey-patient**: Shared stepper component extraction, shared instructions page extraction
- **survey-builder**: New screener settings section for default questionnaire, new access point configurations
- **design_system_flutter**: Shared stepper component, shared instructions page component, medication autocomplete behavior change
- **Backend**: New API endpoint for screener settings, new access point seeds for clinical documents
