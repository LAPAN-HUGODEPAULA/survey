# Repository Guidelines

## Project Structure & Module Organization

- Backend lives in `services/survey-backend/app` (FastAPI) with persistence in `app/persistence/**` and domain models in `app/domain/models`.
- Frontend apps (Flutter) reside under `apps/`: `survey-frontend/`, `survey-patient/`, and `clinical-narrative/`.
- Contracts and generated SDKs live in `packages/contracts/` (`survey-backend.openapi.yaml` and `generated/dart/`). Shared Flutter design system is in `packages/design_system_flutter/`.
- Clinical Writer API (`services/clinical-writer-api`) exposes `/process` with JSON-only ReportDocument output and prompts loaded via PromptRegistry (Google Drive provider).
- Tooling, CI scripts, and migrations are under `tools/`.
- Docs lives in `docs/` with this guidelines file as `AGENTS.md`.

## Build, Test, and Development Commands

- Python package and project manager: use `uv` (https://docs.astral.sh/uv/) to manage venv, dependencies, and run commands.
- Virtual environments lives in `.venv`.
- Add a dependency to the project.toml via `uv add <package>`; for dev dependencies use `uv add -D <package>`.
- Sync the project's dependencies with the environment: `uv sync`.
- Run a command in the project environment: `uv run <command>`.
- Backend type-check/compile: `python -m compileall services/survey-backend/app`.
- Backend run (compose): `docker compose up -d mongodb survey-backend`; local uvicorn: `uv run uvicorn app.main:app --reload --app-dir services/survey-backend/app`.
- Generate API clients: `tools/scripts/generate_clients.sh`.
- Flutter: from each app dir run `flutter pub get` then `flutter analyze`; build web if needed via `flutter build web`.
- Docker build: build one service or app at a time to avoid resource exaustion, e.g. `docker build -t survey-backend`.
- Compose full stack: `docker compose up -d mongodb survey-backend survey-frontend survey-patient`.

## Coding Style & Naming Conventions

- Python: adhere to PEP 8; avoid runtime imports from legacy folders. Only `app/persistence/**` may import `pymongo`.
- FastAPI routers should use dependency-injected repositories from `app.persistence.deps`.
- Dart/Flutter: prefer feature-first structure (`app/`, `features/<feature>/data|domain|presentation`, `shared/`). Use the shared `design_system_flutter` theme with `Colors.orange` primary.
- Filenames: snake_case for Python modules; lower_snake_case for Dart files; use PascalCase for classes/types.

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

## Architecture Principles (Guidance)

- Separation of concerns: keep UI, business logic, and data access in distinct modules.
- DRY + SOLID: avoid duplication; design with single responsibility and dependency on abstractions.
- Layered / Clean Architecture: dependencies must point inward; presentation → business → data with no cross-layer calls.
- Domain-driven design when modeling core flows: define bounded contexts and keep domain logic framework-free.
- API-first for inter-service or client contracts: update OpenAPI/AsyncAPI specs first, then generate SDKs/mocks.
- Microservices/event-driven only when a clear boundary or scale need exists; handlers must be idempotent.
- Cloud-native deployment targets: services should be stateless, container-ready, and expose health checks; use IaC when deploying.
- Prioritize loose coupling, testability, and maintainability over premature optimization.

## Commands

### Linting Guidelines when explicitly requested

- Backend lint: `pylint --disable=C services/survey-backend/app/**.py`
- Backend lint: `pylint --disable=C services/clinical-writer-api/clinical_writer_agent/**.py`
- Flutter lint: `flutter analyze` from each app directory.
- Markdown lint: `markdownlint docs/**.md -fix`
- Markdown lint: `markdownlint services/survey-backend/app/**.py -fix`
- Markdown lint: `markdownlint services/clinical-writer-api/clinical_writer_agent/**.py -fix`

## Testing Guidelines

- Backend: rely on unit-style tests where available; always ensure `python -m compileall` passes before pushing.
- Flutter: run `flutter analyze` per app; favor widget/unit tests colocated under `test/` mirrors.
- Contract generation: re-run `tools/scripts/generate_clients.sh` and verify a clean git diff.

## Commit & Pull Request Guidelines

- Use Conventional Commits with emojis, e. g.,
  - `feat({scope}): ✨ ...`,
  - `fix({scope}): 🐛 ...`,
  - `chore({scope}): 🧹 ...`.
  - `docs({scope}): 📝 ...`
  - `test({scope}): ✅ ...`
  - `ops({scope}): 🚀 ...`
  - `refactor({scope}): ♻️ ...`
- Keep commits small and trunk-friendly; avoid mixing backend, contracts, and Flutter changes in one commit when possible.
- Pull requests should describe scope, testing performed (commands run), and any known gaps; link issues when relevant.

## Security & Configuration Tips

- Configure Mongo via `MONGO_URI`/`MONGO_DB_NAME`; never hardcode secrets—use env vars.
- Clinical writer and email integrations are env-driven in `app/config/settings.py`; keep tokens out of source control.
- PromptRegistry uses Google Drive `modifiedTime` as `prompt_version`; do not embed prompt content in MongoDB.
- Validate that generated clients are up to date before releases to avoid contract drift.

## When stuck

- Ask a clarifying question, propose a short plan, or open a draft PR with notes
