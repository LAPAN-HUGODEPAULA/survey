# Repository Guidelines

## Project Structure & Module Organization
- `apps/`: Flutter clients. `apps/survey-frontend/frontend` is the screener web app; `apps/survey-patient/patient_app` is the patient-facing build; `apps/clinical-narrative` hosts a separate clinical narrative tool.
- `services/`: Back-end services. `services/survey-backend/app` contains the FastAPI code and migrations; `services/clinical-writer-api` and `services/survey-worker` house supporting agents/workers.
- `packages/`: Shared libraries (Flutter design system, contracts, Python shared code).
- `infra/`: Docker, NGINX, and deployment assets; `firebase.json` at the root configures Firebase Functions/hosting.
- `docs/`: Architecture notes, ADRs, and runbooks.

## Build, Test, and Development Commands
- **Backend (FastAPI)**:  
  ```bash
  cd services/survey-backend
  python -m venv .venv && source .venv/bin/activate
  pip install -r requirements.txt
  uvicorn main:app --reload --app-dir app --port 8000
  ```
  Run migrations as needed (e.g., `python app/migrations/migrate_to_mongo_local.py`).
- **Screener frontend** (`apps/survey-frontend/frontend`): `flutter pub get`, then `flutter run -d chrome`. Build web bundle with `./build_survey.sh dockerVps` or `./build_survey.sh firebase`.
- **Patient app** (`apps/survey-patient/patient_app`): `flutter pub get` then `flutter run -d chrome` (add `--dart-define` overrides for screener info if needed).
- **Full stack via Docker**: `docker compose up -d --build` (requires valid `.env` with `MONGO_URI`, etc.; adjust contexts if you move service folders).

## Coding Style & Naming Conventions
- **Dart/Flutter**: Use `dart format .` and `flutter analyze` (rules from `analysis_options.yaml`). Widgets/classes in `PascalCase`, methods/fields in `camelCase`, assets/files in `snake_case`.
- **Python (backend)**: PEP 8 with type hints where possible; prefer dependency-free standard logging (`config/logging_config.py`) instead of `print`. Keep routers lean; put validation in `domain/models` and integrations under `integrations/`.
- Keep configuration and secrets in `.env` files; never commit credentials. Use sample values in docs when adding new settings.

## Testing Guidelines
- Flutter: place tests in each app’s `test/` directory and run `flutter test` (or `flutter test test/my_widget_test.dart` for a single file).
- Backend: add tests under `services/survey-backend/tests`. Install `pytest` in the virtualenv and run `python -m pytest`. Aim to cover API routes and migration scripts; mock external services (email, clinical writer).
- For manual API checks, hit `http://localhost:8000/api/v1/surveys` after starting uvicorn.

## Commit & Pull Request Guidelines
- Follow Conventional Commits observed here: `feat(frontend): …`, `fix(docker): …`, `chore: …` (scoped where helpful; emojis optional). Keep messages in imperative mood.
- PRs should include: brief summary, linked issue (if any), screenshots/GIFs for UI changes, and a “Testing” note with commands run. Mention new env vars, migrations, or breaking changes explicitly.
- Keep diffs focused; prefer smaller, reviewable PRs. Add or update tests when altering behavior.

## Security & Configuration Tips
- Store secrets locally in untracked `.env` files (`services/survey-backend/backend/.env` and root `.env` used by Docker).  
- Restrict CORS/origin lists when deploying; the current dev setup is permissive for local use.  
- Validate incoming payloads via Pydantic models and avoid passing raw request bodies directly into integrations or Mongo drivers.
