## ADDED Requirements

### Requirement: Coverage Measurement
The system SHALL measure line and branch coverage for API, web, and mobile workspaces using platform-native tools.

#### Scenario: Generating workspace coverage reports
- **WHEN** tests are executed in a workspace
- **THEN** machine-readable and human-readable coverage reports are generated

### Requirement: CI Quality Gates
The CI pipeline SHALL enforce minimum test coverage thresholds and block builds that do not meet these targets.

#### Scenario: Build failure on low coverage
- **WHEN** a change reduces test coverage below the minimum threshold
- **THEN** the CI pipeline fails and reports the coverage gap

### Requirement: Full Matrix Execution
The CI pipeline SHALL successfully execute the full suite of backend, web, mobile, and workspace test commands.

#### Scenario: Successful full matrix run
- **WHEN** a change is proposed to the main branch
- **THEN** the full test matrix runs without unexpected failures