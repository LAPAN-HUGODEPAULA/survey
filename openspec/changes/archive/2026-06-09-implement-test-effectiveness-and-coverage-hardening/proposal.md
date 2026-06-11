## Why

Recent work added substantial test surface, but there is still risk of shallow confidence from heavily mocked unit/UI tests. This change ensures the test suite validates real system behavior and not only mocked paths by establishing a repository-wide test quality hardening pass that measures and enforces coverage, and executes the full test matrix mapped to spec acceptance criteria.

## What Changes

- Extract testable acceptance criteria from all active OpenSpec specs.
- Build a traceability matrix mapping spec criteria to existing tests to show coverage status.
- Evaluate current tests for effectiveness, auditing mock-heavy tests.
- Refactor weak tests and add missing tests for unverified criteria/scenarios.
- Add cross-layer validation strategy (unit, integration, contract/API, e2e).
- Generate and publish coverage reports for API, web, and mobile.
- Define minimum coverage and quality gates in CI, failing builds if thresholds aren't met.
- Execute the full test matrix (backend, web, mobile, workspace) and publish a final verification report.

## Capabilities

### New Capabilities
- `test-effectiveness`: Establishing cross-layer validation, mock auditing, and test effectiveness reporting.
- `coverage-enforcement`: Setting up coverage reporting, quality gates in CI, and full matrix execution.
- `spec-traceability`: Extracting criteria from OpenSpec specs and building a traceability matrix.

### Modified Capabilities

## Impact

- **Affected code:** Test suites across all workspaces (API, web, mobile).
- **APIs/Dependencies:** CI/CD pipelines will be updated to include quality gates and coverage enforcement.
- **Systems:** Project-wide validation strategy, OpenSpec integration for traceability.