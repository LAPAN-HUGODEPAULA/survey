# Tasks

- [x] 1. **Centralize Rendering**: Update `tools/scripts/render_runtime_config.py` to include all required AI and service credentials.
- [x] 2. **Refactor `survey-backend`**:
    - Add `pydantic-settings` to dependencies.
    - Migrate `app/config/settings.py` to use `BaseSettings`.
    - Ensure `main.py` continues to call `validate_runtime_security()`.
- [x] 3. **Refactor `clinical-writer-api`**:
    - Add `pydantic-settings` to `pyproject.toml`.
    - Create `clinical_writer_agent/settings.py` using `BaseSettings`.
    - Replace `AgentConfig` usage with the new `settings` instance.
    - Add startup validation call in `main.py`.
- [x] 4. **Refactor `survey-worker`**:
    - Ensure it uses the shared `pydantic-settings` pattern for its environment.
- [x] 5. **Repository Cleanup**:
    - Remove committed `.env` files.
    - Add `.env.example` to `services/clinical-writer-api/clinical_writer_agent/`.
    - Ensure all credentials in `credentials/` are gitignored.
- [x] 6. **Validation**:
    - Rerun Skylos and confirm secret findings are resolved.
    - Verify fail-fast behavior with a script that clears environment variables and attempts service startup.

## Validation

- [x] V1. Run `python3 tools/scripts/render_runtime_config.py` and verify all `.env` files in `config/runtime/generated/private/` are correct.
- [x] V2. Run service startup tests with missing required settings and verify they fail.
- [x] V3. Run Skylos and verify the "Secrets detected" count is reduced to only known false positives (if any).
