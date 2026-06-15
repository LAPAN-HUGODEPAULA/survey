# Tasks

## Phase 1: Foundation & Workspace Initialization

- [x] 1. **Initialize UV Workspace**: Create the root `pyproject.toml` and declare `services/*` and `packages/python/*` as workspace members.
- [x] 2. **Extract `lapan-core`**: 
    - Create `packages/python/lapan-core` package.
    - Move `security_boundaries.py` from all 3 services into the shared package.
    - Refactor imports in all services to use `from lapan_core import ...`.
- [x] 3. **Consolidate Virtual Environment**: Remove `.venv` directories from individual service folders and ensure `uv sync` at the root creates a unified `.venv`.

## Phase 2: The Great Dependency Purge

- [x] 4. **Firebase Cleanup**:
    - Manually grep and remove all `firebase-admin`, `firebase-functions`, and `google-cloud-firestore` imports.
    - Delete any dead adapter code or configuration logic strictly related to Firebase PoCs.
- [x] 5. **Flask & Legacy Cleanup**:
    - Remove `flask`, `flask-cors`, and `a2wsgi` from all manifests.
    - Delete any legacy code referencing Flask.
- [x] 6. **Manual Dependency Audit**:
    - Review `survey-backend/pyproject.toml` and remove transitive/unused dependencies (e.g., `h11`, `h2`, `msgpack`, `cffi`).
    - Verify all remaining dependencies are actually imported in the codebase.
- [x] 7. **Test Cleanup**: Move `pytest`, `pytest-cov`, and `pytest-asyncio` to workspace `dev-dependencies`.

## Phase 3: Modernization & Docker

- [x] 8. **Dependency Version Refresh**: Update all remaining package versions (FastAPI, Pydantic, Pymongo, etc.) to the latest stable versions in the root `uv.lock`.
- [x] 9. **Refactor Dockerfiles**:
    - Update `services/*/Dockerfile` to support root build context.
    - Use multi-stage builds or `uv` efficient sync for production images.
- [x] 10. **Documentation Update**: Update `GEMINI.md` and developer guides to reflect the new `uv workspace` commands.

## Validation

- [x] V1. **Workspace Sync**: Run `uv sync` at the root and verify no version conflicts.
- [x] V2. **Service Boot**: Successfully run `uv run uvicorn...` (or equivalent) for Backend, Agent API, and Worker.
- [x] V3. **Test Suite**: Run `uv run pytest` at the root and ensure all tests pass.
- [x] V4. **Docker Build**: Run `docker-compose build` and verify that images are correctly built using the shared `lapan-core`.
- [x] V5. **Skylos Verification**: Rerun Skylos and confirm that "undeclared dependency" noise is eliminated.
