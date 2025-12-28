# Repository Guidelines

## Project Structure & Module Organization
- Backend lives in `services/survey-backend/app` (FastAPI) with persistence in `app/persistence/**` and domain models in `app/domain/models`.
- Frontend apps (Flutter) reside under `apps/`: `survey-frontend/frontend`, `survey-patient/patient_app`, and `clinical-narrative/clinical_narrative_app`.
- Contracts and generated SDKs live in `packages/contracts/` (`survey-backend.openapi.yaml` and `generated/dart/`). Shared Flutter design system is in `packages/design_system_flutter/`.
- Tooling, CI scripts, and migrations are under `tools/`.

## Build, Test, and Development Commands
- Backend type-check/compile: `python -m compileall services/survey-backend/app`.
- Backend run (compose): `docker compose up -d mongodb survey-backend`; local uvicorn: `uv run uvicorn app.main:app --reload --app-dir services/survey-backend/app`.
- Generate API clients: `tools/scripts/generate_clients.sh`.
- Flutter: from each app dir run `flutter pub get` then `flutter analyze`; build web if needed via `flutter build web`.
- Compose full stack: `docker compose up -d mongodb survey-backend survey-frontend survey-patient`.

## Coding Style & Naming Conventions
- Python: adhere to PEP 8; avoid runtime imports from legacy folders. Only `app/persistence/**` may import `pymongo`.
- FastAPI routers should use dependency-injected repositories from `app.persistence.deps`.
- Dart/Flutter: prefer feature-first structure (`app/`, `features/<feature>/data|domain|presentation`, `shared/`). Use the shared `design_system_flutter` theme with `Colors.orange` primary.
- Filenames: snake_case for Python modules; lower_snake_case for Dart files; use PascalCase for classes/types.

## Testing Guidelines
- Backend: rely on unit-style tests where available; always ensure `python -m compileall` passes before pushing.
- Flutter: run `flutter analyze` per app; favor widget/unit tests colocated under `test/` mirrors.
- Contract generation: re-run `tools/scripts/generate_clients.sh` and verify a clean git diff.

## Commit & Pull Request Guidelines
- Use Conventional Commits with emojis (e.g., `✨ feat: ...`, `🐛 fix: ...`, `🧹 chore: ...`).
- Keep commits small and trunk-friendly; avoid mixing backend, contracts, and Flutter changes in one commit when possible.
- Pull requests should describe scope, testing performed (commands run), and any known gaps; link issues when relevant.

## Security & Configuration Tips
- Configure Mongo via `MONGO_URI`/`MONGO_DB_NAME`; never hardcode secrets—use env vars.
- Clinical writer and email integrations are env-driven in `app/config/settings.py`; keep tokens out of source control.
- Validate that generated clients are up to date before releases to avoid contract drift.
