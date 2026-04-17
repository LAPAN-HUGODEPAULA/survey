# Weekly Change Log

## Week of 2026-04-17

### Features

- **Survey Builder Navigation UX**: On 2026-04-17, improved survey-builder navigation with task-based dashboard, persistent sidebar/bottom navigation, unified admin shell, cross-workflow shortcuts between related tasks (survey↔prompt↔persona flows), responsive design for desktop/mobile, and affective design integration while maintaining performance.
- **Survey Builder Admin Audit Trail**: On 2026-04-17, added comprehensive audit trail tracking all administrative actions with correlation IDs, privacy-compliant data minimization, role-based access controls, and automated 90-day retention with LGPD alignment.
- **Agent Access Point Management**: On 2026-04-17, implemented centralised agent access-point catalog with runtime precedence resolution, multi-artifact Clinical Writer fan-out, thank-you flow integration, and stable access-point keys across survey applications.
- **Survey Builder Admin Security**: On 2026-04-17, secured survey-builder with backend-managed builder admin authorization, dedicated authentication endpoints, signed session cookies, CSRF protection, and session-aware Flutter admin-shell behavior.
- **Clinical Writer Prompt Catalog**: On 2026-04-17, documented questionnaire prompt governance model including taxonomy boundaries, draft-versus-publish lifecycle, bootstrap prompt catalog with Lapan7 decomposition, and admin runbook for safe operations.

### Documentation

- **Deep Research Alignment**: Updated Clinical Writer prompt-catalog research to match access-point runtime model and publish-aware governance workflow.
- **Runtime Migration Guidance**: Added agent access-point runtime runbook documenting precedence, migration steps, and backward-compatibility.
- **Builder Navigation Guide**: Created comprehensive navigation documentation for new task-based dashboard and shell architecture.
- **Audit Trail Documentation**: Added builder audit trail guide covering usage, privacy rules, and incident response procedures.

## Week of 2026-04-12

### Features

- **Survey Builder Security**: On 2026-04-16, added authenticated `survey-builder` admin access using backend-managed `isBuilderAdmin` authorization, dedicated builder auth endpoints, signed session cookies, CSRF protection, and session-aware Flutter admin-shell behavior.
- **Admin Operations**: On 2026-04-16, documented builder-admin promotion and revocation workflow and added the `tools/scripts/set_builder_admin.sh` helper for operational privilege changes.
- **Prompt Catalog Governance**: On 2026-04-17, added the Clinical Writer prompt-governance reference covering questionnaire prompts, persona skills, output profiles, agent access points, privacy rules, and the draft-versus-publish lifecycle.
- **Prompt Bootstrap Pack**: On 2026-04-17, added the reviewed bootstrap prompt catalog with `Lapan7` decomposition, a draft `NeuroCheck` domain prompt, starter prompt and persona records, starter output profiles, and starter access-point defaults.
- **Prompt Operations Runbook**: On 2026-04-17, added the Portuguese admin runbook and the seed handoff plan for translating the reviewed bootstrap documentation into a later Mongo publication change.
- **Access-Point Runtime Management**: On 2026-04-17, added the builder-managed access-point catalog API, runtime precedence resolution, multi-artifact Clinical Writer fan-out, and stable thank-you flow access-point keys across the survey apps.

### Documentation

- **Deep Research Alignment**: Updated the Clinical Writer prompt-catalog research brief to match the planned access-point runtime model, evaluation criteria, and publish-aware governance workflow.
- **Runtime Migration Guidance**: Added the agent access-point runtime runbook documenting precedence, migration steps, fallback expectations, and backward-compatibility behavior for `agentResponse` versus `agentResponses`.

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
