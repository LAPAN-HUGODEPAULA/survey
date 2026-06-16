# Tasks: introduce-python-quality-gates

- [ ] **1. Add Quality Tools to Dev Dependencies**
  - Add `ruff`, `mypy`, `pylint` to `[tool.uv.dev-dependencies]` in root `pyproject.toml`.
  - Sync environment using `uv sync`.

- [ ] **2. Configure Tools in Root pyproject.toml**
  - Add `[tool.ruff]` and `[tool.ruff.lint]` configurations.
  - Add `[tool.mypy]` and module-level overrides configuration.
  - Configure Pylint options if needed under `[tool.pylint]`.

- [ ] **3. Set Up Pre-commit Hooks**
  - Install `pre-commit` (if not available) or set up root `.pre-commit-config.yaml` using local hook entries for:
    - Syntax compiler (`compileall`)
    - Ruff (`ruff check`)
    - Mypy (`mypy`)
    - Pylint (`pylint`)
    - Skylos baseline check (`skylos . --baseline --gate`)
  - Document pre-commit installation command in `AGENTS.md`.

- [ ] **4. Allow Tracking of Skylos Baseline**
  - Update root `.gitignore` to add exception `!.skylos/baseline.json` so the baseline file can be tracked in Git.
  - Stage and commit the baseline file `.skylos/baseline.json`.

- [ ] **5. Implement Unified Quality Gate Runner**
  - Create `tools/scripts/quality_gate.py`.
  - Implement arguments: `--all` (scans all files) and default (uses `git diff` relative to `origin/main` to scan only changed Python files).
  - Chain executions of `compileall`, `ruff check`, `mypy`, `pylint`, and `skylos`.

- [ ] **6. Document Commands in Project Guidelines**
  - Update `AGENTS.md` and `GEMINI.md` to specify pre-commit hooks usage and `quality_gate.py` instructions under section "4. Linting, Validation & Testing".

- [ ] **7. Run Pilot & Verify Gate**
  - Test pre-commit by staging a mock Python change with an unused import or typing error.
  - Verify hook fails and prevents committing.
  - Clean up mock change, verify clean commit passes.

## Validation

- [ ] **V1.** Git commit fails on seeded syntax, lint, type, or Skylos violation.
- [ ] **V2.** Git commit succeeds when files have no new quality regressions.
- [ ] **V3.** `uv run python tools/scripts/quality_gate.py --all` executes successfully on the clean repository.
