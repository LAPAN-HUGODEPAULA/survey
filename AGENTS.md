# Repository Guidelines

## Project Structure & Module Organization

- Backend lives in `services/survey-backend/app` (FastAPI), with persistence in `app/persistence/**` and domain models in `app/domain/models`.
- Frontend apps (Flutter) reside under `apps/`: `survey-frontend/`, `survey-patient/`, and `clinical-narrative/`.
- Contracts and generated SDKs live in `packages/contracts/` (`survey-backend.openapi.yaml` and `generated/dart/`). The shared Flutter design system lives in `packages/design_system_flutter/`.
- Clinical Writer API (`services/clinical-writer-api`) exposes `/process` with JSON-only `ReportDocument` output and prompts loaded via `PromptRegistry` (Google Drive provider).
- Tooling, CI scripts, and migrations live under `tools/`.
- Docs live in `docs/`. This guidance file should remain at the repository root as `AGENTS.md`.

## Build, Test, and Development Commands

- Python package and project manager: use `uv` to manage the virtual environment, dependencies, and command execution.
- The project virtual environment lives in `.venv`.
- Add a dependency with `uv add <package>`; for dev dependencies use `uv add -D <package>`.
- Sync dependencies with the environment using `uv sync`.
- Run commands in the project environment with `uv run <command>`.
- Backend compile check: `uv run python -m compileall services/survey-backend/app`
- Backend run (compose): `docker compose up -d mongodb survey-backend`
- Backend run (local): `uv run uvicorn app.main:app --reload --app-dir services/survey-backend/app`
- Generate API clients: `tools/scripts/generate_clients.sh`
- Flutter: from each app directory, run `flutter pub get`, then `flutter analyze`; build web when needed with `flutter build web`.
- Docker build: build one service or app at a time to avoid resource exhaustion, e.g. `docker build -t survey-backend .`
- Compose full stack: `docker compose up -d mongodb survey-backend survey-frontend survey-patient`

## Coding Style & Naming Conventions

- Python: follow PEP 8. Avoid runtime imports from legacy folders.
- Only `app/persistence/**` may import `pymongo` directly.
- FastAPI routers should use dependency-injected repositories from `app.persistence.deps`.
- Dart/Flutter: prefer a feature-first structure (`app/`, `features/<feature>/data|domain|presentation`, `shared/`).
- Prefer the shared `design_system_flutter` package for theming and reusable UI patterns.
- Filenames: `snake_case` for Python modules, `lower_snake_case` for Dart files, and `PascalCase` for classes and types.

## Commenting Standards

- Write all comments and docstrings in English.
- Prefer comments that explain intent, invariants, edge cases, or non-obvious behavior; avoid narrating obvious code.
- Use language-native documentation formats:
  - Python: `"""triple double quote"""` docstrings following PEP 257.
  - Dart: `///` doc comments for libraries, public types, and members that benefit from context.
  - Java: `/** ... */` Javadoc when editing handwritten Java code.
- Keep comments concise and maintain them when code changes.
- Replace stale implementation-history comments such as `Added`, `Changed`, or similar patch notes with intent-focused documentation or remove them.
- Exclude generated or scaffolded files from manual comment cleanup unless they contain custom handwritten logic.
- Add author tags only when a tool or format explicitly requires them; use `Hugo de Paula`.

## Architecture Principles

- Keep UI, business logic, and data access in distinct modules.
- Avoid duplication; prefer single responsibility and dependency on abstractions.
- Maintain layered or clean architecture boundaries: presentation → business → data, with no cross-layer shortcuts.
- Use domain-driven design concepts when modeling core flows: define bounded contexts and keep domain logic framework-free where practical.
- Treat service and client contracts as API-first artifacts: update OpenAPI or AsyncAPI specs first, then generate SDKs or mocks.
- Use microservices or event-driven patterns only when there is a clear boundary or scaling need; handlers must be idempotent.
- Prefer stateless, container-ready services with health checks for deployment targets.
- Prioritize loose coupling, testability, and maintainability over premature optimization.

## Commands

### Linting and Validation Commands

Run these when relevant to the files changed, or when explicitly requested.

- Backend lint: `pylint --disable=C services/survey-backend/app/**/*.py`
- Clinical Writer API lint: `pylint --disable=C services/clinical-writer-api/clinical_writer_agent/**/*.py`
- Flutter lint: run `flutter analyze` from each affected app directory.
- Markdown lint: `markdownlint docs/**/*.md --fix`

## Testing Guidelines

- Backend: rely on unit-style tests where available; always ensure `uv run python -m compileall services/survey-backend/app` passes before pushing.
- Flutter: run `flutter analyze` for each affected app; favor widget and unit tests colocated under mirrored `test/` directories.
- Contract generation: re-run `tools/scripts/generate_clients.sh` when relevant and verify the resulting git diff is intentional and clean.
- When changing backend request or response models, validate whether the OpenAPI contract and generated clients must also change.

## Commit & Pull Request Guidelines

- Use Conventional Commits with emojis, e.g.:
  - `feat(scope): ✨ add ...`
  - `fix(scope): 🐛 fix ...`
  - `chore(scope): 🧹 update ...`
  - `docs(scope): 📝 document ...`
  - `test(scope): ✅ add tests ...`
  - `ops(scope): 🚀 deploy ...`
  - `refactor(scope): ♻️ refactor ...`
- Keep commits small and trunk-friendly.
- Avoid mixing backend, contracts, and Flutter changes in one commit unless the change genuinely spans those layers.
- Pull requests should describe scope, commands run for validation, and any known gaps.
- Link related issues when relevant.

## Git Workflow

- Never push directly to `main`.
- Always work on a branch.
- Open a pull request for any code change.
- Prefer pull requests with focused scope.
- When making changes as an automated agent, prefer opening or updating a pull request rather than pushing directly to a protected branch.

## Security & Configuration Tips

- Configure MongoDB via `MONGO_URI` and `MONGO_DB_NAME`; never hardcode secrets.
- Clinical Writer and email integrations are environment-driven in `app/config/settings.py`; keep credentials and tokens out of source control.
- `PromptRegistry` uses Google Drive `modifiedTime` as `prompt_version`; do not embed prompt content in MongoDB.
- Validate generated clients before releases to avoid contract drift.
- Avoid logging secrets, raw tokens, or sensitive patient or clinical payloads.

## Review Guidelines

### General

- Focus on correctness, security, maintainability, and regressions introduced by the PR.
- Flag only actionable issues.
- Prefer comments tied to changed lines when possible.
- Ignore purely stylistic nits unless they harm readability or violate established team conventions.

### FastAPI Backend

- Verify routers use dependency-injected repositories from `app.persistence.deps`.
- Verify no new runtime imports from legacy folders are introduced.
- Verify only `app/persistence/**` imports `pymongo` directly.
- Check request and response contracts against `packages/contracts/survey-backend.openapi.yaml` when relevant.
- Watch for secret leakage, environment misuse, unsafe logging, and broken validation assumptions.
- Watch for business logic leaking into routing or persistence layers.

### Flutter Apps

- Check feature-first structure consistency.
- Flag UI changes that bypass `design_system_flutter` without justification.
- Watch for state-management regressions, null-safety mistakes, async lifecycle issues, and unnecessary widget duplication.
- Prefer maintainable widget composition over large monolithic widgets.

### Monorepo and Contracts

- When backend contract changes are introduced, verify generated clients were updated.
- Flag mixed changes spanning backend, contracts, and Flutter when there is no clear reason for coupling.
- Remind authors when testing or validation evidence is missing from the PR description.

### Validation Expectations

- Backend-relevant changes should pass:
  - `uv run python -m compileall services/survey-backend/app`
- Flutter-relevant changes should pass:
  - `flutter analyze`
- Contract-relevant changes should be checked with:
  - `tools/scripts/generate_clients.sh`

## When Stuck

- Ask a clarifying question if a requirement is ambiguous.
- Propose a short plan before making broad or risky changes.
- If work is partially complete, summarize blockers clearly before opening or updating a draft PR.
