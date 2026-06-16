# Documentation Index

Authoritative documentation for the LAPAN Survey Platform. This repository is a monorepo with a FastAPI backend, Flutter web applications, a Clinical Writer AI service, shared contracts/design system packages, and supporting tooling.

## Doc Map

### Architecture & Design

- [Overview](overview.md)
- [Requirements](requirements.md)
- [Technical Specification](technical-specification.md)
- [Software Design](software-design.md)
- [Multi-Agent Architecture](multiagent-architecture.md)
- [API Documentation](api-documentation.md)
- [Privacy Governance](privacy-governance.md)

### Diagrams

- [LangGraph Pipeline](diagrams/langgraph-pipeline.md)
- [System Architecture](diagrams/system-architecture.md)
- [AI Config Resolution](diagrams/ai-config-resolution.md)
- [Authorization Dependency Pattern](diagrams/auth-dependency-pattern.md)

### User Guides

- [User Guides Index](user-guides/README.md)
- [Clinical Narrative User Guide](user-guides/clinical-narrative.md)

### Runbooks & Operations

- [Runtime Config Runbook](runbooks/runtime-config.md)
- [Survey Builder Admin Access Runbook](runbooks/survey-builder-admin-access.md)
- [Access Point Runtime Runbook](runbooks/access-point-runtime.md)
- [Deployment Plan](deployment-plan.md)

### Builder Guides

- [Survey Builder Runbook (pt-BR)](guides/survey-builder-runbook.md)
- [Prompt Editing Runbook](runbooks/prompt-editing.md)

### Plans & Research

- [Builder Admin Agent Roadmap](plans/survey-builder-admin-agent-roadmap-2026-04.md)
- [Clinical Prompt Catalog Seed Handoff](plans/clinical-prompt-catalog-seed-handoff.md)

### Version History

- [Release Notes](release-notes.md)
- [Weekly Changelog](changelog-weekly.md)

## How to Use

- Start with the Overview and Requirements for context.
- Consult the Software Design for implementation details per component.
- Use the Multi-Agent Architecture doc for the Clinical Writer deep-dive.
- Use the diagrams for visual references to system topology, data flows, and authorization patterns.
- API consumers should rely on `packages/contracts/survey-backend.openapi.yaml` and generated SDKs.
- Operational guides are in the Runbooks section; version history lives in Release Notes and the weekly changelog.
