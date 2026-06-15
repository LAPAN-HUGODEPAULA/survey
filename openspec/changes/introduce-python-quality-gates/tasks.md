# Tasks

- [ ] 1. Decide supported quality tools: existing pylint plus optional Ruff and mypy/pyright.
- [ ] 2. Create configuration files with generated/irrelevant exclusions.
- [ ] 3. Define baseline files for existing findings and fail only on new violations initially.
- [ ] 4. Add changed-file quality command for local development.
- [ ] 5. Add CI/pre-commit entrypoints for compile, lint, type check, and Skylos differential report.
- [ ] 6. Document validation commands in AGENTS.md or tooling docs.
- [ ] 7. Pilot on one small service module before enforcing repository-wide.

## Validation

- [ ] V1. Quality command exits nonzero for a seeded new violation.
- [ ] V2. Baseline report generated and documented.
- [ ] V3. CI/pre-commit runs on representative changed files.
