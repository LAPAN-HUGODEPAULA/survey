# Change: formalize-python-service-packaging

## Why

The current Python service structure consists of isolated silos with duplicated utility code, redundant virtual environments, and a significant amount of "zombie" dependencies (Flask, Firebase, PoC leftovers). This results in high maintenance overhead, version drift, and noisy static-analysis reports (Skylos v1 reported 263 undeclared dependencies). 

Transitioning to a formalized monorepo workspace using `uv` will unify the dependency management, consolidate the development environment into a single root `.venv`, and provide a clean foundation for future growth.

## What Changes

- **Unified UV Workspace**: Convert the repository into a `uv` workspace with a single root `uv.lock`.
- **Shared Utility Package**: Extract duplicated logic (like `security_boundaries.py`) into a shared internal package: `packages/python/lapan-core`.
- **The "Great Purge"**: Manually audit and remove all unused or obsolete dependencies, specifically:
    - **Flask & Ecosystem**: `flask`, `flask-cors`, `a2wsgi`.
    - **Firebase Ecosystem**: `firebase-admin`, `firebase-functions`, `google-cloud-firestore`.
- **Dependency Refresh**: Update remaining core dependencies (FastAPI, Pydantic, Pymongo, etc.) to their latest stable and compatible versions.
- **Docker Modernization**: Update `Dockerfiles` to use `uv` and support the workspace-root build context, ensuring lean service-specific images.
- **Single Source of Truth**: Consolidate Python versioning (>=3.13) across the entire platform.

## Scope

- Root workspace configuration (`pyproject.toml`, `uv.lock`).
- Service manifests (`services/*/pyproject.toml`).
- Creation of `packages/python/lapan-core`.
- Deletion of dead code associated with Firebase/Flask PoCs.
- Docker configuration and deployment manifests (docker-compose).

## Impact

- **Affected capability**: `python-platform`
- **Refactor leverage**: Very High. Collapses duplicated code and stabilizes the foundation.
- **Confidence**: High for structural changes; Medium-High for dependency removal (requires manual grep verification).
- **Expected implementation style**: Large-scale foundational refactor. Must preserve existing FastAPI contracts while cleaning the underlying plumbing.

## Evidence From Skylos v1

- Skylos reports 263 undeclared dependency rows. Most are caused by the lack of workspace-aware package roots (e.g., `app` and `clinical_writer_agent` treated as third-party).
- **Note on Static Analysis**: Skylos reports are treated as "Discovery Signals" only. Due to high false-positive rates in local import resolution, all dependency removals MUST be verified by grepping the codebase for actual usage.

## Non-Goals

- Do NOT perform broad formatting-only rewrites.
- Do NOT change external API contracts (OpenAPI) unless a task explicitly requires a fix for a broken model.
- Do NOT implement new business features.
- Do NOT fix unrelated frontend bugs.
