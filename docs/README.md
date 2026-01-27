# Documentation Index

Authoritative documentation for the LAPAN Survey Platform. This repository is a monorepo with a FastAPI backend, Flutter web applications, a Clinical Writer AI service, shared contracts/design system packages, and supporting tooling.

## Doc Map

- [Overview](overview.md)
- [Requirements](requirements.md)
- [Technical Specification](technical-specification.md)
- [Software Design](software-design.md)
- [API Documentation](api-documentation.md)
- [Deployment Plan](deployment-plan.md)
- [Release Notes](release-notes.md)
- [Weekly Changelog](changelog-weekly.md)

## How to Use

- Start with the Requirements and Technical Specification for context.
- Consult the Software Design for implementation details per component.
- API consumers should rely on `packages/contracts/survey-backend.openapi.yaml` and generated SDKs.
- Operational guides are in the Deployment Plan; version history lives in Release Notes and the weekly changelog.
