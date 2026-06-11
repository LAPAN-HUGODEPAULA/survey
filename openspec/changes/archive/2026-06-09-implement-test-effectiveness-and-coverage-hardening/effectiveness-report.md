# Test Effectiveness Report

## Audit Findings

### 1. Mock Overuse in Backend Repositories
- **Severity**: Medium
- **Finding**: Most repository tests in `services/survey-backend/tests/` (e.g., `test_screener_repo.py`, `test_survey_router.py`) use manual `_FakeDatabase` and `_FakeCollection` classes.
- **Risk**: These mocks only implement a subset of MongoDB functionality. They cannot validate index constraints, complex query behavior, or actual Pydantic-to-Mongo serialization edge cases.
- **Recommendation**: Introduce real MongoDB integration tests using a test database (e.g., using `pytest-docker` or a dedicated test Mongo container) for core repositories.

### 2. Shallow Router Tests
- **Severity**: Low
- **Finding**: Router tests mock the entire repository layer.
- **Risk**: Validates that the router calls the repo, but doesn't validate that the end-to-end flow from HTTP request to DB persistence works.
- **Recommendation**: Add at least one integration test per critical entity (Survey, Screener, Response) that goes from `TestClient` to a real test database.

### 3. AI Service Mocking
- **Severity**: High
- **Finding**: Tests for clinical narrative generation often mock the LLM responses.
- **Risk**: Does not catch regressions in prompt formatting or changes in LLM behavior/API contracts.
- **Recommendation**: Implement contract tests that validate the request/response schema against the real (or a high-fidelity local) AI service.

### 4. Flutter Widget Testing
- **Severity**: Medium
- **Finding**: Many Flutter tests are basic widget tests (`widget_test.dart`) that check for existence of text/widgets.
- **Risk**: Does not validate complex state management or navigation flows.
- **Recommendation**: Expand to integration tests (using `integration_test` package) for critical user journeys like survey completion and screener registration.

## Weak Tests Identified

- `services/survey-backend/tests/test_screener_repo.py`: Uses `_FakeDatabase`. Should use real Mongo for `ensure_system_screener`.
- `services/survey-backend/tests/test_survey_router.py`: Heavily mocked.
- `apps/survey-builder/test/widget_test.dart`: Generic placeholder.

## Refactor Decisions

- **Priority 1**: Replace `_FakeDatabase` with a real test MongoDB for critical repositories in `survey-backend`.
- **Priority 2**: Add integration tests for `survey-patient` and `survey-frontend` assessment flows.
- **Priority 3**: Implement contract tests for `clinical-writer-api`.
