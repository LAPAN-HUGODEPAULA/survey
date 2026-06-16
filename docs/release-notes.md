# Release Notes

## v0.2.0 – Survey Builder & Governance Features

### Added

- 2026-04-17: improved survey-builder navigation with task-based dashboard, persistent sidebar/bottom navigation, unified admin shell component, cross-workflow shortcuts between related tasks, responsive design for desktop/mobile layouts, and affective design integration maintaining performance
- 2026-04-17: implemented comprehensive audit trail system tracking all administrative actions with correlation IDs, privacy-compliant data minimization, role-based access controls, and automated 90-day retention with LGPD alignment
- 2026-04-17: added centralised agent access-point catalog with runtime precedence resolution, multi-artifact Clinical Writer fan-out, thank-you flow integration, and stable access-point keys across survey applications
- 2026-04-17: documented Clinical Writer prompt-catalog governance model including questionnaire prompts taxonomy, draft-versus-publish lifecycle, bootstrap prompt catalog with Lapan7 decomposition, and Portuguese admin runbook
- 2026-04-17: created survey builder navigation guide, audit trail documentation, and responsive design specifications for the new administrative interface

### Changed

- survey-builder now uses task-oriented navigation replacing data-focused summaries
- navigation persists across sections without forcing returns to dashboard
- unified component strategy reduces specialized widgets while maintaining affective design
- audit system provides traceability for security, debugging, and compliance
- access points resolve runtime configuration with multi-artifact fan-out support
- prompt catalog work has explicit documentation as precursor to Mongo seed publication

### Fixed

- navigation dead-ends in survey-builder persona and prompt management
- audit trail privacy concerns with automated PII detection and content redaction
- mobile navigation responsiveness with adaptive breakpoints and touch targets
- session management consistency across Flutter admin shell components

## Unreleased

- 2026-06-16: centralized FastAPI authorization contracts — `require_screener`/`require_template_admin` dependency pattern, removed legacy `settings.template_admin_emails`, added route authorization audit test.
- 2026-06-15: formalized Python service packaging as UV workspace with single `uv.lock`, shared `packages/python/lapan-core`, removed zombie dependencies.
- 2026-06-12: hardened file and URL boundaries with `security_boundaries.py` utility (path traversal + SSRF protection).
- 2026-06-11: hardened runtime secrets config with `pydantic-settings`, centralized secret rendering, fail-fast startup validation.
- 2026-06-10: refactored survey-builder authoring flow to controller pattern (ChangeNotifier), extracted form widgets, externalized validators.
- 2026-06-10: cleaned up 631 unused Flutter imports across all apps.
- 2026-06-09: configured AI agent catalog with MongoDB-backed `AIAgents` collection and ordered `agentRefs` routing.
- 2026-06-09: implemented test effectiveness and coverage hardening with cross-layer validation strategy and traceability matrix.
- 2026-06-15: updated architecture, API, runbook, and diagram documentation to reflect May-June 2026 changes.

- 2026-05-07: completed AI governance hard cut to canonical `aiConfig` across backend, worker, clinical-writer, and builder, retiring runtime usage of legacy flat AI fields.
- 2026-05-07: added global AI settings endpoints (`GET/PUT /settings/ai`) and enforced runtime precedence chain (`Request > Access Point > Global > Environment fallback`).
- 2026-05-07: finalized clinical-writer executor-only routing behavior with structured stage/routing logs and request correlation identifiers.
- 2026-05-07: implemented survey-worker bounded retries (`WORKER_MAX_RETRIES`) with terminal `permanently_failed` state and persisted diagnostics (`retryCount`, `lastError`, `agentResponseUpdatedAt`).
- 2026-05-07: completed survey-builder global AI settings UX and explicit inheritance controls for access points.
- 2026-05-07: synchronized API/architecture/runbook/admin documentation to the aiConfig-only governance model and worker operational knobs.
- 2026-05-07: validated rollout with passing targeted backend/worker/clinical-writer tests, passing clinical-writer lint, and clean `flutter analyze` for survey-builder.

- 2026-04-16: secured `survey-builder` administrative access with backend-managed builder admin authorization, dedicated builder login and logout endpoints, signed session cookies, CSRF enforcement for write operations, and protected Flutter admin-shell session bootstrap and recovery flows.
- 2026-04-16: added builder-admin operational support materials, including administrator promotion and revocation guidance and the `tools/scripts/set_builder_admin.sh` helper.
- 2026-04-17: documented the Clinical Writer prompt-catalog governance model, including taxonomy boundaries for questionnaire prompts, persona skills, output profiles, and planned agent access points.
- 2026-04-17: added the reviewed bootstrap prompt catalog with `Lapan7` decomposition, a draft `NeuroCheck` domain prompt, starter questionnaire and persona records, starter output profiles, and starter access-point defaults marked as not yet published seed material.
- 2026-04-17: added the Portuguese builder-admin runbook for safe prompt-catalog operations and the seed handoff documentation for a later Mongo publication change.
- 2026-04-17: expanded the Deep Research brief to align prompt refinement work with the access-point-oriented runtime model and publish-aware versioning workflow.
- 2026-04-17: added builder-managed agent access-point APIs, runtime precedence resolution, and thank-you flow access-point integration across `survey-builder`, `survey-patient`, and `survey-frontend`.

### Changed

- builder-managed backend routes now require authenticated builder-admin sessions rather than relying on open access.
- survey-builder prompt-governance work now has explicit documentation as the authoritative precursor to any Mongo seed publication.
- survey-driven Clinical Writer orchestration now resolves runtime configuration through request overrides, then access points, then survey defaults, with multi-artifact fan-out returned in `agentResponses` while preserving `agentResponse` for compatibility.

### Release Planning Notes

- The May AI governance hardening, June security hardening, agent catalog, authorization centralization, and packaging formalization constitute a coherent release candidate.
- The next SemVer tag should be cut as **v0.3.0** after validation of the complete feature set.

## v0.1.0 – Initial SemVer Baseline

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
