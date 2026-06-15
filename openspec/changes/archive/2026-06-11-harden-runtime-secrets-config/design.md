# Design: harden-runtime-secrets-config

## Goals

- **Unified Configuration**: All Python services use `pydantic-settings` for environment-driven configuration.
- **Centralized Source of Truth**: `config.private.json` is the sole source for secrets, rendered via `tools/scripts/render_runtime_config.py`.
- **Fail-Fast Startup**: Services validate their configuration on startup and refuse to run if critical security requirements are not met.
- **Zero-Secret Repo**: No real secrets or credentials tracked in git.

## Decisions

- **BaseSettings Inheritance**: Each service will define a `Settings` class inheriting from `pydantic_settings.BaseSettings`.
- **Field-Level Validation**: Use Pydantic's validation (e.g., `SecretStr`, `min_length`) to enforce configuration quality.
- **Rendering Expansion**: `render_runtime_config.py` will be expanded to map the following from `config.private.json` to `clinical-writer.env`:
    - `GEMINI_API_KEY`
    - `GLM_API_KEY`
    - `GLM_BASE_URL`
    - `GEMINI_MODEL`
    - `GLM_MODEL`
    - `PRIMARY_MODEL`
    - `FALLBACK_MODEL`
    - `GOOGLE_APPLICATION_CREDENTIALS` (path within container)
    - `GOOGLE_DRIVE_FOLDER_ID`
    - `AI_API_KEY` (The token used by the backend to talk to the AI service)
- **Deployment via Docker**: Services will read their environment from the `.env` files generated in `config/runtime/generated/private/`.

## Validation Strategy

- **Startup Tests**: Verify services fail to start when required environment variables are missing.
- **Secret Scanning**: Rerun Skylos to ensure no secrets remain in the tracked code or `.env` templates.
- **Integration Test**: Verify that `render_runtime_config.py` correctly populates all environment files needed for a successful `docker compose up`.
