# Weekly Change Log

## Week of 2026-02-01

### Features
- **Screener Management**: Implemented screener registration, login, and profile management functionality.
- **Survey UX**: Added a progress indicator to the survey flow for better user feedback.
- **Database Migrations**: Introduced a consolidated script for running database migrations.

### Fixes
- **Clinical Writer**: Resolved a bug causing internal errors by ensuring a `request_id` is always present.
- **Screener**: The screener's profile is now correctly returned after registration.
- **UI**: Addressed various UI issues, including button labels and navigation bugs.
- **Dependencies**: Updated deprecated `datetime` calls and upgraded the `fl_chart` library, refactoring the Radar Chart implementation.

### Tooling & Build Process
- **API Client Generation**: The `generate_clients.sh` script has been updated to be a single, unified command that now automatically runs `build_runner` to generate Dart data models after producing the client code from the OpenAPI spec.
- **Web Build**: The build process for the web applications now correctly triggers the code generation step (`build_runner`) before compiling.

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
