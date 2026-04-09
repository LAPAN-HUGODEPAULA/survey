# Documentation Index

Authoritative documentation for the LAPAN Survey Platform. This repository is a monorepo with a FastAPI backend, Flutter web applications, a Clinical Writer AI service, shared contracts/design system packages, and supporting tooling.

## Doc Map

- [Overview](overview.md)
- [Requirements](requirements.md)
- [Technical Specification](technical-specification.md)
- [Software Design](software-design.md)
- [User Guides](user-guides/README.md)
- [Clinical Narrative User Guide](user-guides/clinical-narrative.md)
- [Usability & Accessibility Audit](usability-audit.md)
- [API Documentation](api-documentation.md)
- [Deployment Plan](deployment-plan.md)
- [Runtime Config Runbook](runbooks/runtime-config.md)
- [Release Notes](release-notes.md)
- [Weekly Changelog](changelog-weekly.md)

## How to Use

- Start with the Requirements and Technical Specification for context.
- Consult the Software Design for implementation details per component.
- Use the User Guides section for application workflows and operator-facing instructions.
- API consumers should rely on `packages/contracts/survey-backend.openapi.yaml` and generated SDKs.
- Operational guides are in the Deployment Plan; version history lives in Release Notes and the weekly changelog.
