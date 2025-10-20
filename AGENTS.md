# Repository Guidelines

This survey platform pairs a FastAPI backend (`db/`) with a Flutter client (`survey_app/`). Follow these guardrails to keep changes deployable.

## Project Structure & Module Organization
- `db/`: FastAPI entry point in `main.py`, routers in `routers/`, data models in `models/`, environment-aware settings in `config/`, migration scripts under `migrate/`, and seed JSON in `assets/`.
- `survey_app/`: Flutter code; UI and state live in `lib/`, reusable JSON forms in `assets/surveys`, mocked responses in `assets/survey_responses`, and automated tests in `test/`.
- `docs/`: Source of truth for architecture, data contracts, and setup. Update relevant Markdown when changing APIs, schemas, or deployment steps.
- `GEMINI.md`: AI agent brief. Mirror any new agent responsibilities here and in this guide when workflows change.

## Build, Test, and Development Commands
- Backend containers: `cd db && docker-compose up -d --build` rebuilds the API and MongoDB; use `docker-compose logs -f survey_fastapi` to inspect runtime issues.
- Local backend without Docker: `cd db && uvicorn main:app --reload --host 0.0.0.0 --port 8000` (requires Python 3.10+ and project dependencies installed).
- Populate sample data: `cd db && python migrate/migrate_to_mongo.py` loads surveys from the Flutter assets.
- Flutter app: `cd survey_app && flutter pub get && flutter run -d chrome`; run `flutter run` with a device ID for mobile targets.
- Static analysis and formatting: `cd survey_app && flutter analyze` plus `dart format lib test`.

## Coding Style & Naming Conventions
- Dart uses the Flutter lint set from `analysis_options.yaml`. Keep two-space indentation, `UpperCamelCase` for widgets and classes, and `lowerCamelCase` for members. Always run `dart format` (or `flutter format`) before committing.
- Python modules should stay PEP 8 compliant with snake_case filenames, typed signatures, and module-level imports (no relative imports in FastAPI routers). Log sensitive details sparingly; reuse the structured logging configured in `config/logging_config.py`.

## Testing Guidelines
- Flutter tests belong in `survey_app/test` and follow the `*_test.dart` naming convention. Prefer widget tests for UI flows plus small unit tests for services. Execute `flutter test` prior to any review.
- The backend currently lacks automated suites; when adding business logic, create `db/tests/` with `pytest` and hit endpoints against the Docker Mongo instance. Verify migrations locally by re-running `python migrate/migrate_to_mongo.py` after schema changes.
- Aim for coverage on critical survey submission and response persistence paths even without a formal threshold.

## Commit & Pull Request Guidelines
- Match the existing history: `<type>(<scope>): <emoji> <short imperative>` (example: `feat(app): :sparkles: add offline sync`). Scopes typically map to `app`, `db`, or finer-grained modules.
- Keep commits focused and bilingual only when necessary—avoid mixing Portuguese and English within the same message.
- Pull requests need a concise summary, test command checklist, linked issues, and screenshots or screen recordings for UI updates. Call out schema changes, required migrations, or new env vars upfront.

## Configuration & Security Notes
- Backend secrets load from `db/.env` via `config/system_settings.py`; never commit real credentials. Update a shared `.env.example` when adding keys like `MAIL_*`.
- Survey fixtures reside in `survey_app/assets`; scrub PHI and respect anonymization before committing new datasets.
