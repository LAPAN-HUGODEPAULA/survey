# Delta for code-quality

## ADDED Requirements

### Requirement: Baseline-Aware Quality Gate

Python quality checks SHALL prevent new high-confidence findings while allowing existing baseline debt to be retired incrementally.

#### Scenario: New violation blocked

- GIVEN a Python change introduces a new high-confidence unused import or unauthenticated mutating route finding, WHEN quality gates run, THEN the check MUST fail.

#### Scenario: Existing baseline tolerated

- GIVEN a finding exists in the frozen baseline and the touched code does not worsen it, WHEN quality gates run, THEN the check MAY pass while still reporting the debt.

### Requirement: Generated and Irrelevant Exclusions

Quality tooling SHALL consistently exclude generated analyzer cache, virtual environments, build output, and non-Python lockfile false positives from Python backend quality scoring.

#### Scenario: Generated cache ignored

- GIVEN .skylos/cache files are present, WHEN quality gates run, THEN they MUST NOT be treated as application code.

