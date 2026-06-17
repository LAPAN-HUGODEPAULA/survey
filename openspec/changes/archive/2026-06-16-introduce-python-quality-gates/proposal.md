# Change: introduce-python-quality-gates

## Why

Without quality gates, the project will repeatedly accumulate the same typing, complexity, duplicate-code, and analyzer-noise findings. A baseline-aware gate lets you improve incrementally without blocking all work on legacy debt.

## What Changes

- Add a baseline-aware Python quality policy for backend services.
- Introduce type checking and linting configuration gradually, not as a big-bang cleanup.
- Track existing Skylos baseline separately from new findings.
- Add pre-commit or CI checks for changed Python files.

## Scope

Repository Python tooling and validation scripts. Does not require immediate remediation of every existing typing or complexity finding.

## Impact

- Affected capability: `code-quality`
- Refactor leverage: Medium-high
- Confidence: High
- Expected implementation style: focused PR, preserve external behavior unless the spec explicitly changes it.

## Evidence From Skylos v1

- Quality rows include 131 typing issues, 43 complexity issues, 49 structure issues, 26 architecture rows, 18 clone rows, and 3 repo policy rows.
- Repo policy rows report no mypy/pyright policy, no Ruff policy config, and no pre-commit policy file.
- AGENTS.md already lists compile and pylint validation expectations for backend and Clinical Writer API work.

## Non-Goals

- Do not perform unrelated formatting churn.
- Do not change API contracts unless a task explicitly requires OpenAPI/spec updates.
- Do not suppress findings without documenting whether they are generated noise, first-party import context, test-only scope, or proven false positives.
