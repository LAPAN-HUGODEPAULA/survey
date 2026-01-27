# Weekly Change Log

## Week of 2025-12-27

### Backend

- Confirmed FastAPI routers for surveys, survey responses, and patient responses under `/api/v1` with MongoDB-backed repositories.
- Background email tasks and Clinical Writer enrichment paths documented; OpenAPI contract remains the single source of truth.

### Worker & AI

- Survey worker configured to poll MongoDB and submit pending responses to the Clinical Writer service with status tracking.
- Clinical Writer architecture captured (LangGraph pipeline, classification strategies, AgentConfig-driven setup).

### Frontend

- Flutter apps aligned on shared `design_system_flutter` theme (seed color `Colors.orange`).
- Clients expected to consume generated Dart SDK from the contracts package.

### Infrastructure

- Root Docker Compose orchestrates MongoDB, survey-backend, worker, and the three Flutter web apps; Clinical Writer runs via its own compose file when needed.

### Documentation

- Repository documentation reset with authoritative requirements, design, API, deployment, release notes, and changelog.
