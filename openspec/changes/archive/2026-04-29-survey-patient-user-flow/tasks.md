## 1. Backend: New Persona & Access Point Seeds

- [x] 1.1 Add `patient_condition_report` persona to `tools/migrations/survey-backend/prompt_catalog_seed.py` (key, name, outputProfile, instructions for detailed clinical report)
- [x] 1.2 Add `survey_patient.report.detailed_analysis` access point to `tools/migrations/survey-backend/access_point_seed.py` (promptKey: `survey7`, personaSkillKey: `patient_condition_report`, outputProfile: `patient_condition_report`)
- [x] 1.3 Run both seed scripts against local MongoDB to create the persona and access point
- [x] 1.4 Verify the auto-analysis access point `survey_patient.thank_you.auto_analysis` is still working correctly (query the database, confirm it exists with `patient_condition_overview` persona)

## 2. Runtime Access Point Catalog

- [x] 2.1 Add `surveyPatientReportDetailedAnalysis` descriptor to `packages/runtime_agent_access_points/lib/runtime_agent_access_points.dart` with `availability: configurable`
- [x] 2.2 Add it to the `configurable` and `all` lists in `RuntimeAccessPointCatalog`

## 3. Fix Survey-Builder 409 Error

- [x] 3.1 In `apps/survey-builder/lib/features/survey/pages/agent_access_point_form_page.dart`, add a pre-creation check: before POST, call `GET /agent_access_points/{key}` to detect existing records
- [x] 3.2 If the access point already exists, switch from `_repository.createAccessPoint(draft)` to `_repository.updateAccessPoint(draft)` automatically
- [x] 3.3 Handle the 409 response gracefully in `_save()` — if 409 is returned despite the check, retry with PUT

## 4. Patient Identification Screen

- [x] 4.1 Create `apps/survey-patient/lib/features/identification/pages/patient_identification_page.dart` with name, email, birth date fields using `DsPatientIdentitySection`
- [x] 4.2 Implement form submission that stores patient data via `AppSettings.setPatientData()` and navigates to welcome page
- [x] 4.3 Add `toIdentification()` and `replaceWithIdentification()` methods to `AppNavigator`
- [x] 4.4 Update `initial_notice_page.dart` to navigate to the identification page instead of the welcome page after notice acceptance
- [x] 4.5 Update `PatientJourneyStepper` if needed to reflect the new step in the flow

## 5. Simplify Demographics Page

- [x] 5.1 Remove the "Identificação" DsSection from `apps/survey-patient/lib/features/demographics/pages/demographics_page.dart`
- [x] 5.2 Remove the "Adicionar informações é opcional" DsHandoffFork skip section
- [x] 5.3 Make all remaining fields in "Dados complementares" truly optional (no required validation for this page)
- [x] 5.4 Keep the "Gerar relatório detalhado" continue button and navigation to report

## 6. External Specialist Link on Thank-You Page

- [x] 6.1 Add a new `DsSection` "Converse com o especialista" to `apps/survey-patient/lib/features/survey/pages/thank_you_page.dart` after the "Avaliação preliminar" section
- [x] 6.2 Include explanatory text about the Irlen Syndrome GPT being an external LAPAN project
- [x] 6.3 Add a button/link that opens `https://chatgpt.com/g/g-699b668db91c8191877e65ba10726cd2-irlen-syndrome-for-teachers-and-educators` via `url_launcher`

## 7. Report Page Timeout Fix

- [x] 7.1 Refactor `ReportPage._maybeFetchAgentResponse()` to always use the async task-based approach (`startClinicalWriterTask` + polling) matching `ThankYouPage._startAndPollAgentResponse`
- [x] 7.2 Remove the synchronous `processClinicalWriter` fallback call
- [x] 7.3 Show explicit timeout error with retry option when polling exceeds the limit
- [x] 7.4 Use the `survey_patient.report.detailed_analysis` access point for the "Gerar relatório" flow (via access point selection)

## 8. Email Report Delivery

- [x] 8.1 Create `POST /v1/patient_responses/{response_id}/send_report_email` endpoint in `services/survey-backend/app/api/routes/patient_responses.py`
- [x] 8.2 Implement server-side PDF generation from report text (using `fpdf2` or similar lightweight library)
- [x] 8.3 Extend `services/survey-backend/app/integrations/email/service.py` to support PDF attachments in emails
- [x] 8.4 Add "Enviar relatório por e-mail" `DsFilledButton` to `apps/survey-patient/lib/features/report/pages/report_page.dart`
- [x] 8.5 Disable the button when no patient email is available or report is not loaded
- [x] 8.6 Show success/error toast feedback after email send attempt

## 9. Verification

- [x] 9.1 Verify new persona `patient_condition_report` exists in database via survey-builder UI
- [x] 9.2 Verify access point `survey_patient.report.detailed_analysis` is configurable in survey-builder without errors
- [x] 9.3 Manual test: complete full flow (notice → identification → welcome → survey → thank-you → report) and verify all navigation works
- [x] 9.4 Manual test: verify report page no longer times out and generates a detailed report
- [x] 9.5 Manual test: verify email delivery works (requires SMTP configuration)
- [x] 9.6 Run Flutter tests in `apps/survey-patient`
