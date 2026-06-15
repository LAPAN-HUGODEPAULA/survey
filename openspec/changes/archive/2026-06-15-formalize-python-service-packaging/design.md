# Design: formalize-python-service-packaging

## Context

This change was initiated following a Skylos Python report triage, which identified significant noise in dependency analysis. It has evolved into a foundational refactor to adopt a modern Python monorepo structure.

## Goals

- Establish a unified **UV Workspace** for the entire LAPAN Survey Platform.
- Eliminate "Zombie" dependencies (Flask, Firebase) and clean up leftover PoC code.
- Extract shared Python logic into a version-consistent internal package.
- Simplify development workflows with a single root `.venv`.
- Modernize all dependency versions.

## Non-Goals

- Implementing new business logic.
- Rewriting the database layer (preserving MongoDB).
- Refactoring frontend code.

## Decisions

- **UV Workspace**: We will use a single `uv.lock` at the root. All services (`services/*`) and shared packages (`packages/python/*`) will be workspace members.
- **`lapan-core` Package**: We will create `packages/python/lapan-core` to house shared security helpers, common Pydantic models, and utility functions.
- **Manual Dependency Audit**: We will NOT trust static analysis (Skylos) for deletions. We will grep the codebase for `import` statements and usage before removing any package.
- **Docker Context**: Docker builds will now be executed from the **repository root**. Dockerfiles will be refactored to use `uv` and copy the root configuration first.
- **Version Refresh**: We will bump all maintained dependencies to their latest compatible major/minor versions.

## Risks / Trade-offs

- **Build Context Shift**: CI/CD and local build scripts must be updated to run from the root, which can break existing manual `docker build` commands inside service directories.
- **Dependency Conflicts**: A single `uv.lock` requires all services to share the same version of common packages. While this is a benefit for consistency, it may initially uncover version conflicts between services.
- **PoC Deletion**: Removing Firebase/Flask code requires careful verification that no secondary features (like specific audit logs or legacy integrations) still rely on them.

## Validation Strategy

- **`uv sync`**: Must succeed at the root with no conflicts.
- **`uv run` Execution**: All three services (`survey-backend`, `clinical-writer-api`, `survey-worker`) must boot successfully in the new workspace.
- **Automated Tests**: Existing test suites must pass using the root `.venv`.
- **Docker Verification**: `docker-compose build` must succeed from the root for all services.
- **Static Analysis Rerun**: Skylos findings for "undeclared dependencies" should disappear as local packages are correctly identified as first-party members.
