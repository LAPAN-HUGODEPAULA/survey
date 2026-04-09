## 1. Standardized Error Response Model

- [x] 1.1 Define `ApiError` Pydantic model in `services/survey-backend/app/domain/models/error_model.py`.
- [x] 1.2 Implement global `HTTPException` handler in `services/survey-backend/app/api/errors.py`.
- [x] 1.3 Register the global error handler in `services/survey-backend/app/main.py`.
- [x] 1.4 Update OpenAPI specification in `packages/contracts/survey-backend.openapi.yaml` with the new error schema.

## 2. Asynchronous Job Pattern and AI Progress

- [x] 2.1 Standardize AI processing stages enum/literals across the platform.
- [x] 2.2 Implement a reusable background task manager or extend `clinical_writer.py` logic.
- [x] 2.3 Update `/clinical_writer/process` to support `async_mode` by default for long reports.
- [x] 2.4 Enhance `/clinical_writer/status/{task_id}` to return granular stages and pt-BR messages.
- [x] 2.5 Update Clinical Writer Agent nodes to report stage transitions to the task store.

## 3. Contract Enhancements for Recovery

- [x] 3.1 Update authentication login route to return structured error codes (e.g., `INVALID_CREDENTIALS`).
- [x] 3.2 Modify password recovery endpoint to return a generic success response for all requests.
- [x] 3.3 Add explicit contract identifiers for expired survey links and unauthorized access.

## 4. Verification and Documentation

- [x] 4.1 Verify new error response format via manual API testing (Postman/Curl).
- [x] 4.2 Verify asynchronous polling flow for a sample clinical report.
- [x] 4.3 Regenerate API clients using `./tools/scripts/generate_clients.sh`.
- [x] 4.4 Update technical documentation with the new error and progress reporting standards.
