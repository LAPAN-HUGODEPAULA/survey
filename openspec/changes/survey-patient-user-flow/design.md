## Context

The survey-patient flow currently follows: Initial Notice → Welcome → Survey → Thank You → (optional) Demographics → Report. Patient identification (name, email, birth date) lives inside the demographics page which is entirely optional and can be skipped. This means most survey responses are anonymous.

The thank-you page uses `survey_patient.thank_you.auto_analysis` access point (already seeded and functional) with `patient_condition_overview` persona to generate a preliminary AI assessment. The "Gerar relatório" button navigates to demographics → report, but there's no dedicated access point for detailed report generation — the report page reuses the same clinical writer endpoint.

The survey-builder returns 409 when trying to create access points because the target persona must already exist in the database. Since `patient_condition_report` persona doesn't exist, the backend returns 422 (unknown personaSkillKey), not 409. The actual 409 occurs when an access point key already exists (e.g., trying to recreate `survey_patient.thank_you.auto_analysis`).

The report page has a timeout because `_maybeFetchAgentResponse` falls back to a synchronous `processClinicalWriter` call which can take too long for complex reports.

## Goals / Non-Goals

**Goals:**
- Make patient identification mandatory and early in the flow
- Create `patient_condition_report` persona and `survey_patient.report.detailed_analysis` access point
- Fix the access point creation in survey-builder by ensuring all dependencies exist
- Add Irlen Syndrome GPT external link to thank-you page
- Add email-with-PDF report delivery to report page
- Fix report page timeout

**Non-Goals:**
- Changing the survey-frontend flow (only survey-patient)
- Modifying the AI agent integration architecture
- Building a PDF generation engine from scratch (use existing browser print for PDF)
- Adding SMS or other notification channels

## Decisions

### D1: Patient identification screen placement

Insert `PatientIdentificationPage` between `initial_notice_page.dart` and `welcome_page.dart`. This page contains only name, email, and birth date fields (the `DsPatientIdentitySection` widget). After submission, patient data is stored via `AppSettings.setPatientData()` and the patient is persisted to the database immediately (not deferred to survey response submission). Navigation continues to `WelcomePage`.

**Alternatives considered:**
- Before survey instead of before welcome: Too late — we want identification before anything else
- After welcome but before survey: Adds friction before the core task; identification is not needed to start the survey

### D2: Simplified demographics page

Remove the "Identificação" DsSection and the "Adicionar informações é opcional" `DsHandoffFork` skip section from `DemographicsPage`. Keep only "Dados complementares" with all fields optional. The form controller's required-field validation for name/email/birthDate is removed from this page since identification is now handled upstream.

### D3: Patient data storage strategy

Patient data is saved to `AppSettings` immediately on the identification page. When the survey response is eventually submitted (on the thank-you page or report page), the patient data from settings is included. This ensures all responses have patient data even if the user never reaches the demographics page.

### D4: patient_condition_report persona

Create a new persona skill with key `patient_condition_report`, output profile `patient_condition_report`, and instructions focused on generating a detailed, structured clinical report in Brazilian Portuguese. This differs from `patient_condition_overview` which produces a concise summary. The new persona focuses on comprehensive diagnostic analysis with structured sections.

### D5: survey_patient.report.detailed_analysis access point

New access point with:
- `accessPointKey`: `survey_patient.report.detailed_analysis`
- `sourceApp`: `survey-patient`
- `flowKey`: `report.detailed_analysis`
- `promptKey`: `survey7` (default "Triagem de pacientes")
- `personaSkillKey`: `patient_condition_report`
- `outputProfile`: `patient_condition_report`

Register this in the `RuntimeAccessPointCatalog` as a configurable access point.

### D6: Report timeout fix

The report page timeout occurs because `_maybeFetchAgentResponse` uses `repository.processClinicalWriter()` as a fallback synchronous call. The fix is to always use the async task-based approach (`startClinicalWriterTask` + polling), matching the pattern already used in `ThankYouPage._startAndPollAgentResponse`. If the async approach fails, show an explicit error instead of blocking on a synchronous call.

### D7: Email PDF delivery

Add a `POST /v1/patient_responses/{id}/send_report_email` endpoint that:
1. Fetches the survey response with agent response
2. Generates a PDF (server-side using the report text)
3. Sends via `fastapi_mail` with the PDF attached

Frontend: Add a `DsFilledButton` "Enviar relatório por e-mail" to the report page that calls this endpoint. The button is only enabled when the report is successfully loaded and the patient has an email.

### D8: External specialist link section

Create a simple `DsSection` on the thank-you page with:
- Title: "Converse com o especialista"
- Description explaining the GPT is an external LAPAN project focused on visual distress and learning
- `DsOutlinedButton` or `DsLinkButton` opening the URL in a new tab/browser

No shared component needed — this is a one-off section specific to the thank-you page.

### D9: 409 error root cause

The 409 in survey-builder occurs when:
1. User selects `survey_patient.thank_you.auto_analysis` from the injection point dropdown
2. The form pre-fills the access point key
3. User submits → POST to `/api/v1/agent_access_points/`
4. If the access point already exists (seeded), MongoDB raises `DuplicateKeyError` → 409

The fix: The survey-builder should detect that a configurable access point already exists and either:
- Switch to PUT (update) instead of POST (create)
- Or show a pre-creation check that warns the user

Additionally, creating `patient_condition_report` persona and `survey_patient.report.detailed_analysis` access point in seeds ensures the builder can configure them without validation errors.

## Risks / Trade-offs

- [Mandatory identification may reduce survey completion] → Only 3 fields (name, email, birth date); keep it minimal. Email could be made optional if completion rates drop.
- [Patient stored before survey response] → Creates orphan patient records if user abandons the flow. Acceptable since the data is minimal.
- [PDF generation server-side adds dependency] → Use a lightweight library (e.g., `fpdf2` or `weasyprint`). Start with plain-text email and add PDF as enhancement.
- [New persona quality depends on prompt engineering] → The persona instructions can be iterated independently via the prompt management UI.
