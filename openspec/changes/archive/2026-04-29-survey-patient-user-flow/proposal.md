## Why

The survey-patient flow has a critical gap: patient identification is optional and buried in the demographics page, meaning most responses arrive without patient data — making the system clinically useless. Additionally, the "Gerar relatório" button lacks a dedicated AI access point (currently sharing the auto-analysis persona), the report page times out, there's no email export, and users have no path to external Irlen Syndrome expertise.

## What Changes

- **Split demographics page into two screens**: Move the "Identificação" section (name, email, birth date) into a new mandatory patient identification screen shown right after the initial notice page. The demographics page keeps only "Dados complementares" (all optional), and removes the "Adicionar informações é opcional" skip section since users can go directly to report from the thank-you page.
- **New persona and access point for detailed report**: Create `patient_condition_report` persona with `patient_condition_report` output profile, and a new access point `survey_patient.report.detailed_analysis` that uses the default "Triagem de pacientes" prompt + this persona.
- **Fix survey-builder 409 error**: The access point creation fails because `patient_condition_report` persona doesn't exist yet. Seeding the persona resolves the validation chain (backend validates personaSkillKey exists and outputProfile matches).
- **Verify thank-you auto-analysis access point**: Confirm that `survey_patient.thank_you.auto_analysis` with `patient_condition_overview` persona is already working (it is — seeded and used in `ThankYouPage`).
- **Add AI summary to thank-you "Avaliação preliminar" section**: The auto-analysis access point already produces an AI summary; verify it renders correctly in the `DsClinicalContentCard`.
- **Fix report page timeout**: Investigate and resolve the timeout issue when generating the detailed report.
- **Add external specialist link**: Create a new `DsSection` "Converse com o especialista" on the thank-you page with a link to the Irlen Syndrome GPT.
- **Add email report button**: Add a "Enviar relatório por e-mail" button to the report page that sends the report as PDF to the patient's email.

## Capabilities

### New Capabilities
- `patient-identification-screen`: Mandatory patient identification screen between initial notice and welcome/survey, storing all patients in the database
- `patient-condition-report-persona`: New persona skill for detailed clinical report generation
- `detailed-report-access-point`: New access point `survey_patient.report.detailed_analysis` for the "Gerar relatório" button
- `email-report-delivery`: Backend and frontend support for sending the generated report as PDF to patient email
- `external-specialist-link`: DsSection with Irlen Syndrome GPT link on the thank-you page

### Modified Capabilities
- `patient-survey-flow`: Navigation flow changes (new identification screen after notice, simplified demographics, removed skip section)
- `shared-flutter-component-library`: Reusable external link section component
- `generate-clinical-documents`: Report page gains email delivery and timeout fix

## Impact

- **apps/survey-patient**: New `PatientIdentificationPage`, modified `DemographicsPage` (removed identification + skip section), modified `ThankYouPage` (external link), modified `ReportPage` (email button, timeout fix), modified `AppNavigator` (new routes)
- **services/survey-backend**: New persona seed (`patient_condition_report`), new access point seed (`survey_patient.report.detailed_analysis`), new email-with-PDF endpoint, timeout fix in clinical writer processing
- **tools/migrations/survey-backend**: Updated `prompt_catalog_seed.py` and `access_point_seed.py`
- **packages/runtime_agent_access_points**: New catalog entry for detailed report access point
- **packages/design_system_flutter**: New `DsExternalLinkSection` widget
