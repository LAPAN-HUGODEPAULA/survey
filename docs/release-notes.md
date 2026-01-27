# Release Notes

## v1.0.0 – Monorepo Baseline

### Highlights

- Consolidated monorepo layout across services, apps, packages, and tools.
- FastAPI survey backend using repository + DI pattern with MongoDB persistence.
- Clinical Writer AI service documented and integrated via worker/background tasks.
- Shared Flutter design system with `Colors.orange` theme across all apps.
- Contract-first API with generated Dart/Python SDKs.
- Docker Compose stack for backend, worker, and Flutter web apps.

### Breaking Changes

- Legacy documentation and references to deprecated layouts removed.
- App-specific compose files replaced by the root compose definition.
- Manual HTTP client usage deprecated in favor of generated SDKs.

### Migration Notes

- Use the root `docker-compose.yml` for local and production deployments.
- Regenerate SDKs from `packages/contracts/survey-backend.openapi.yaml` when the contract changes.
- Route all MongoDB access through repository/dependency injection patterns.
