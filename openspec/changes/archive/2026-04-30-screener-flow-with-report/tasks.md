## 1. Backend Screener Defaults and API Contracts

- [x] 1.1 Add `system_settings` persistence support for `screener_default_questionnaire_id` in `services/survey-backend`, including lookup of questionnaire name for read responses.
- [x] 1.2 Implement `GET /v1/settings/screener` and `PUT /v1/settings/screener` with questionnaire existence validation and response payload fields `default_questionnaire_id` and `default_questionnaire_name`.
- [x] 1.3 Ensure startup fallback resolves `CHYPS-V Br Q20` when no explicit default is set, then persists the resolved questionnaire ID for subsequent sessions.
- [x] 1.4 Update OpenAPI contract and generated clients (`packages/contracts/survey-backend.openapi.yaml` + generated SDKs) for the new screener settings endpoints and models.

## 2. Survey Builder Admin Settings for Screener

- [x] 2.1 Add a screener settings section in `apps/survey-builder` with questionnaire dropdown, current default pre-selection, and save action.
- [x] 2.2 Wire screener settings UI to `GET/PUT /v1/settings/screener` and show success/error feedback states.
- [x] 2.3 Display active default questionnaire context in builder admin flow to reduce misconfiguration risk.

## 3. Survey Frontend Startup Questionnaire Behavior

- [x] 3.1 Load screener settings at `survey-frontend` app startup and initialize active questionnaire automatically when a default exists.
- [x] 3.2 Keep manual questionnaire selection flow only as fallback when no default can be resolved.
- [x] 3.3 Update the "Sessão profissional ativa" information block to show the active questionnaire name used for the current screener session.

## 4. Shared Stepper and Title Alignment

- [x] 4.1 Extract or finalize shared `DsFlowStepper` in `packages/design_system_flutter` based on `PatientJourneyStepper` visual language and state behavior.
- [x] 4.2 Replace `AssessmentFlowStepper` usage in `apps/survey-frontend` with the shared stepper so screener UI matches patient flow.
- [x] 4.3 Update `apps/survey-patient` to consume the same shared stepper component to avoid design drift.
- [x] 4.4 Center AppBar titles across screener flow pages (demographics, clinical context, instructions, questionnaire, thank-you, and report), including `"Avaliação do paciente"` in `demographics_page.dart`.

## 5. Medication Autocomplete Performance Refactor

- [x] 5.1 Refactor medication autocomplete in `packages/design_system_flutter` to fetch medication catalog once on first use and cache it in memory.
- [x] 5.2 Replace per-keystroke network search with local, case-insensitive in-memory filtering for suggestion rendering.
- [x] 5.3 On manual medication insertion, append immediately to local memory and persist asynchronously after field blur without blocking form interaction.
- [x] 5.4 Add retryable error handling for async persistence failures while preserving local user-entered medication values.

## 6. Shared Instructions Screen and Scroll Behavior

- [x] 6.1 Extract the working instructions content/structure from `apps/survey-patient` into a shared component in `packages/design_system_flutter`.
- [x] 6.2 Replace screener instructions page implementation with the shared component to guarantee parity.
- [x] 6.3 Ensure "Confirme as instruções" section is vertically scrollable on constrained viewports in screener flow.

## 7. Screener Thank-You Page Behavior Updates

- [x] 7.1 Remove colored question labels from the "Radar das respostas" section in `apps/survey-frontend/lib/features/survey/pages/thank_you_page.dart`.
- [x] 7.2 Remove the entire "Resumo das respostas" section from screener thank-you page while keeping radar content.
- [x] 7.3 Add `DsSection` titled "Avaliação preliminar" and reuse the same async analysis UX pattern from `apps/survey-patient`.
- [x] 7.4 Verify and wire routing key "Análise automática do questionário profissional" (`survey_frontend.thank_you.auto_analysis`) to default prompt `triagem de pacientes` + persona `patient_condition_overview`.
- [x] 7.5 Add "Gerar Relatório" action in screener thank-you page with the same interaction pattern used in `survey-patient`.

## 8. Access Point Catalog and Seeding for Screener Reports/Documents

- [x] 8.1 Seed new access point `screener.report.detailed_analysis` labeled "Relatório clínico detalhado do paciente" with prompt `full_intake` and persona `clinical_diagnostic_report`.
- [x] 8.2 Seed access points for "Geração de carta de encaminhamento clínico", "Geração de carta de encaminhamento escolar", and "Geração de carta de orientação aos pais".
- [x] 8.3 Ensure survey-builder runtime access point catalog exposes all screener keys (including `survey_frontend.thank_you.auto_analysis`) and supports create/update flows without duplicate-key errors.

## 9. Screener Report Page and Actions

- [x] 9.1 Create `report_page.dart` in `apps/survey-frontend` using `survey-patient` report flow as baseline with async generation and polling.
- [x] 9.2 Navigate to report page from thank-you "Gerar Relatório" action, carrying assessment context and using detailed report access point.
- [x] 9.3 Add "Enviar relatório por e-mail" button to send final report PDF to patient email with disabled/validation state when email is missing.
- [x] 9.4 Add buttons for "Encaminhamento clínico", "Encaminhamento escolar", and "Orientação aos pais", each mapped to its corresponding access point and loading/error states.

## 10. Validation and Release Readiness

- [x] 10.1 Run backend compile validation: `uv run python -m compileall services/survey-backend/app`.
- [x] 10.2 Run contract/client sync when backend contract changes: `tools/scripts/generate_clients.sh` and verify intentional diffs.
- [x] 10.3 Run `flutter analyze` in `apps/survey-frontend`, `apps/survey-patient`, and `apps/survey-builder`.
- [x] 10.4 Execute end-to-end smoke test for screener flow: startup default questionnaire, instructions scroll, medication autocomplete responsiveness, thank-you AI summary, report generation, and referral document actions.
