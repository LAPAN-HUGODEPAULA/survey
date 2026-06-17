# code-quality Specification

## Purpose
TBD - created by archiving change introduce-python-quality-gates. Update Purpose after archive.
## Requirements
### Requirement: Baseline-Aware Quality Gate

Python quality checks SHALL prevent new high-confidence findings while allowing existing baseline debt to be retired incrementally.

#### Scenario: New violation blocked

- GIVEN a Python change introduces a new high-confidence unused import, syntax error, or unauthenticated mutating route finding, WHEN quality gates run, THEN the check MUST fail.

#### Scenario: Existing baseline tolerated

- GIVEN a finding exists in the frozen baseline and the touched code does not worsen it, WHEN quality gates run, THEN the check MAY pass while still reporting the debt.

### Requirement: Generated and Irrelevant Exclusions

Quality tooling SHALL consistently exclude generated analyzer cache, virtual environments, build output, and non-Python lockfile false positives from Python backend quality scoring.

#### Scenario: Generated cache ignored

- GIVEN `.skylos/cache` files are present, WHEN quality gates run, THEN they MUST NOT be treated as application code.

### Requirement: Pre-commit Quality Enforcement

All Python changes SHALL be validated locally using pre-commit hooks prior to staging/commit.

#### Scenario: Pre-commit check runs on modified files

- GIVEN a developer attempts to commit changes in a Python file, WHEN the pre-commit hook runs, THEN it MUST execute Ruff linting, Mypy type validation, and Pylint checks on the modified files, and it MUST abort the commit if any checks fail.

#### Scenario: Pre-commit gitignore alignment

- GIVEN the pre-commit configuration, WHEN pre-commit runs, THEN it MUST skip files excluded in `.gitignore` (including `.venv/`, `.skylos/`, etc.).

### Requirement: Unified Quality Command

A single, unified tooling command SHALL be provided to run all quality gate validations (syntax, linting, typing, and Skylos baseline diff) locally and on CI.

#### Scenario: Full codebase run on CI

- GIVEN a CI build pipeline, WHEN the quality runner is executed with the `--all` option, THEN it MUST check all Python files in the repository and fail if any new violations (outside the baseline) are found.

#### Scenario: Quick diff scan locally

- GIVEN local development, WHEN the quality runner is executed without `--all`, THEN it MUST determine the files changed relative to `origin/main` and check only those files to ensure fast feedback.

