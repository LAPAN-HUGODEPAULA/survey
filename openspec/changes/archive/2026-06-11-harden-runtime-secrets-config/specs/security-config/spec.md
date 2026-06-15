# Delta for security-config

## ADDED Requirements

### Requirement: Repository Secret Boundary

The system SHALL NOT store live credentials, API keys, tokens, or patient-service secrets in tracked repository files.

#### Scenario: Tracked runtime env file

- GIVEN a file named .env under services/, WHEN repository secret scanning runs, THEN the scan MUST fail unless the file contains only non-secret placeholders.

#### Scenario: Generated analyzer cache

- GIVEN generated analyzer cache files under .skylos/cache/, WHEN secret scanning runs, THEN findings from those files MAY be suppressed by rule rather than treated as application secrets.

### Requirement: Configuration Startup Validation

The Clinical Writer API SHALL validate required runtime configuration at startup without exposing secret values.

#### Scenario: Missing credential

- GIVEN a required credential is absent, WHEN the service starts, THEN startup MUST fail with a non-secret diagnostic naming the missing setting.

#### Scenario: Diagnostic safety

- GIVEN a credential is present, WHEN logs or health checks are emitted, THEN the credential value MUST NOT be logged or returned.

