# Tasks

- [ ] 1. Characterize current patient and survey response behavior with route/service tests.
- [ ] 2. Extract response creation use cases that receive repositories via app.persistence.deps.
- [ ] 3. Extract ReportTextResolver and ReportTextFormatter into a shared module.
- [ ] 4. Extract attachment generation with safe-path helper dependency.
- [ ] 5. Add explicit response_model or return type annotations to create/send/resend/get routes.
- [ ] 6. Remove duplicated _report_dict_to_text implementations.
- [ ] 7. Add tests for email attachment generation, missing reports, malformed report dictionaries, and access-link/screener linkage.
- [ ] 8. Rerun compile, tests, and Skylos.

## Validation

- [ ] V1. Compile survey-backend.
- [ ] V2. Route tests for patient_responses and survey_responses.
- [ ] V3. Skylos complexity reductions in create_patient_response/create_survey_response and report formatter helpers.
