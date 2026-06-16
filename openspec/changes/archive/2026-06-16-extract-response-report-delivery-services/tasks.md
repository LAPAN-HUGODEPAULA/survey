# Tasks

- [x] 1. Characterize current patient and survey response behavior with route tests.
- [x] 2. Extract the `ClinicalTextResolver` to find and extract clinical text from response records.
- [x] 3. Implement the `ReportlabPDFCompiler` to generate PDF bytes using ReportLab.
- [x] 4. Implement the `SendReportCommand` DTO and the `ReportDeliveryService` to handle command execution.
- [x] 5. Extract `PatientSubmissionOrchestrator` and `SurveySubmissionOrchestrator` to coordinate configuration, saving, and agent invocation.
- [x] 6. Refactor `patient_responses.py` and `survey_responses.py` route handlers to delegate to the orchestrators and delivery service.
- [x] 7. Remove `fpdf2` imports and dependencies from `pyproject.toml` and clean up environment packages.
- [x] 8. Add tests for `ReportDeliveryService` (using mock email transport), orchestrators, and ReportLab PDF layout.
- [ ] 9. Verify that git tree is clean and compile/run all tests successfully.

## Validation

- [x] V1. Compile survey-backend and run all 189 tests successfully.
- [x] V2. Confirm `fpdf2` imports are fully removed.
- [x] V3. Ensure Skylos complexity gates are satisfied on refactored routes.
