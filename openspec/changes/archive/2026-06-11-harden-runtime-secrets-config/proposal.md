# Change: harden-runtime-secrets-config

## Why

Committed runtime credentials and inconsistent configuration management across services create immediate operational risk, operational overhead, and poison static-analysis baselines. Adopting a unified, type-safe configuration pattern is a high-leverage security and quality improvement.

## What Changes

- **Adopt `pydantic-settings`**: Formalize configuration management across all Python services (`survey-backend`, `survey-worker`, `clinical-writer-api`) using `pydantic-settings`.
- **Centralize Secret Rendering**: Update `tools/scripts/render_runtime_config.py` to include all AI-specific credentials and configuration for the Clinical Writer API, making it the single source of truth for all service environments.
- **Fail-Fast Validation**: Enforce strict startup validation that prevents services from starting if required credentials or configuration are missing or insecure in production mode.
- **Repository Hygiene**: Remove committed `.env` files and credentials from tracked source, replacing them with `.env.example` templates and centralized rendering.
- **Secret Scanning Alignment**: Update scanner exclusions to focus on real secrets while ignoring generated noise (e.g., caches, lockfile hashes).

## Scope

Configuration management, secret rendering, and repository hygiene for `survey-backend`, `survey-worker`, and `clinical-writer-api`. Does not change API contracts or business logic except for startup initialization.

## Impact

- Affected capability: `security-config`
- Refactor leverage: Very high
- Confidence: High
- Expected implementation style: Unified configuration models, centralized rendering script updates.

## Evidence From Skylos v1

- Secrets detected in `services/clinical-writer-api/clinical_writer_agent/.env`.
- Fragmented configuration patterns: `survey-backend` uses Pydantic but manual `os.getenv`; `clinical-writer-api` uses a custom class without startup validation.
- `render_runtime_config.py` lacks coverage for Clinical Writer AI keys.

## Non-Goals

- Do not change API contracts.
- Do not perform unrelated business logic refactoring.
- Do not migrate database schemas.
