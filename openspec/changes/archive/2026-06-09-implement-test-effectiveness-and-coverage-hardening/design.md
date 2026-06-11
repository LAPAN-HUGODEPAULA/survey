## Context

Recent feature work has expanded the application's surface area. While the test suite has grown, a heavy reliance on mocked unit and UI tests limits confidence in the system's actual behavior during integration and regression. To ensure platform stability, we need to enforce real behavioral validation mapped to OpenSpec acceptance criteria.

## Goals / Non-Goals

**Goals:**
- Implement a clear mapping between OpenSpec criteria and executed tests.
- Measure and enforce test coverage across all components (API, Web, Mobile).
- Audit and strengthen existing tests, reducing over-reliance on mocks.
- Execute full test matrix in CI with quality gates.

**Non-Goals:**
- Completely eliminating all mocks (valid boundaries still apply).
- Major refactoring of feature implementations unrelated to testing.
- Extreme performance optimizations of the test suite beyond stabilization.

## Decisions

- **Traceability Method**: We will build an artifact (traceability matrix) mapping OpenSpec `Scenario` entries to specific test files and blocks to ensure all normative criteria are verified.
- **Coverage Tooling**: We will use language-specific coverage tools (`pytest-cov` for Python backend, `flutter test --coverage` for Dart frontends) and aggregate them in CI.
- **Test Layering**: We will implement a layered strategy—isolated unit tests for logic, integration tests for DB/API boundaries, and E2E tests for critical user journeys.
- **CI Enforcement**: We will add minimum threshold checks in CI (branch/line coverage targets) that will fail the build if not met.

## Risks / Trade-offs

- **Risk: Increased CI Time** → Mitigation: Run unit and integration tests in parallel where possible; keep E2E tests focused on critical paths.
- **Risk: Flaky Tests** → Mitigation: Enforce strict isolation in integration tests and implement automatic retries for transient E2E failures if necessary, though root cause fixes are preferred.
- **Risk: High Refactoring Effort** → Mitigation: Prioritize auditing and refactoring tests that cover high-risk or complex business logic first.