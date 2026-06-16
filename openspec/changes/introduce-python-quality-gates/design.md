# Design: introduce-python-quality-gates

## Context

This change was produced from Skylos Python report v1 triage. The intent is to convert static-analysis clusters into a bounded, reviewable quality policy and tooling gate that runs locally via pre-commit and centrally on CI.

## Goals

- Establish local pre-commit gates to prevent new quality regressions before they are committed.
- Introduce Ruff (lint/format), Mypy (type checking), Pylint, and Skylos (baseline-aware gate) configurations.
- Allow legacy code to exist while ensuring newly modified code is checked.
- Provide a unified script `tools/scripts/quality_gate.py` that developers can run locally.

## Non-Goals

- Complete remediation of all 2,000+ existing codebase findings.
- Global, automated code formatting refactors (like black/ruff format) on legacy files that were not touched.

## Decisions

### 1. Unified Tool Integration
We will configure Ruff, Mypy, and Pylint in the root `pyproject.toml` (or specific configs) to establish standard settings.
- **Ruff**: Enforces imports sort (`I`), code formatting and style (`E`, `W`, `F`), and common code smells (`B`, `C4`, `UP`, `ARG`).
- **Mypy**: Enforces basic strictness (`check_untyped_defs = true`, `strict_equality = true`) with custom package overrides for libraries without types (like `reportlab`, `pymongo`).
- **Pylint**: Standard code complexity and style checking.

### 2. Pre-commit Pipeline
A `.pre-commit-config.yaml` file will be created at the root of the repository to intercept git commits and run the quality gates on staged files.

```yaml
repos:
  - repo: local
    hooks:
      - id: syntax-check
        name: Syntax Check
        entry: uv run python -m compileall -q
        language: system
        types: [python]
      - id: ruff
        name: Ruff Check
        entry: uv run ruff check --force-exclude
        language: system
        types: [python]
      - id: mypy
        name: Mypy Check
        entry: uv run mypy
        language: system
        types: [python]
        pass_filenames: true
      - id: pylint
        name: Pylint Check
        entry: uv run pylint --disable=C
        language: system
        types: [python]
      - id: skylos
        name: Skylos Baseline Gate
        entry: uvx skylos . --baseline --gate
        language: system
        pass_filenames: false
        always_run: true
```

### 3. Unified Quality Gate Runner
A Python script at `tools/scripts/quality_gate.py` will allow running all checks manually:
- `uv run tools/scripts/quality_gate.py --all`: Scans the whole repo (used on CI).
- `uv run tools/scripts/quality_gate.py`: Detects changed files relative to `origin/main` and runs the linter/type-check only on those files, with Skylos verifying the diff.

## Risks / Trade-offs

- **Pre-commit friction**: Running slow checks on every commit can annoy developers. We mitigate this by configuring Ruff (extremely fast) and running Mypy/Pylint only on changed files.
- **Mypy Import Resolution**: When mypy runs on single files, it still resolves imports. It might complain about other files. We will use `ignore_missing_imports` and config overrides to suppress noise.
- **Baseline Drift**: When refactoring code, developers must run `uvx skylos baseline .` to update the baseline file once legacy items are resolved.

## Validation Strategy

- **Seeded failure**: Verify that adding an unused import or typing error to a staged file triggers pre-commit failure.
- **Baseline check**: Ensure `uvx skylos . --baseline --gate` exits with status `0` when no new violations exist.
