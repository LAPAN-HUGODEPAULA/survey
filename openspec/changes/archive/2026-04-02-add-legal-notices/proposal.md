# Change: Add Platform Legal Notices

## Why
The Survey platform needs consistent in-app legal notice presentation to comply with LGPD transparency expectations and to make the Terms of Use and Privacy Policy available from every app. The platform also needs a durable acknowledgement workflow for the initial notice so patient and professional entry flows enforce the required agreement without duplicating UI or losing traceability.

## What Changes
- Add a shared legal footer link in all four Flutter apps so users can open the full `Termo de Uso e Política de Privacidade` from within the app with consistent formatting.
- Add a reusable in-app legal document viewer or modal pattern that renders the full markdown content of the legal documents in Brazilian Portuguese.
- Require `survey-patient` users to acknowledge the initial notice before entering the patient flow, and require acknowledgement again when starting a new assessment from the thank-you screen.
- Require authenticated screeners in `survey-frontend` and `clinical-narrative` to acknowledge the initial notice once for the whole platform when no prior agreement date exists.
- Store a single platform-wide screener agreement timestamp and add a MongoDB migration that introduces the new field without data loss for existing screener documents.
- Reuse `packages/design_system_flutter` for shared footer, legal viewer, and acknowledgement UI so the legal experience does not diverge across apps.

## Capabilities

### New Capabilities
- `legal-notice-management`: Define platform-wide legal document access, in-app rendering, and initial-notice acknowledgement rules across the Survey applications.

### Modified Capabilities
- `patient-survey-flow`: The public patient flow must be gated by the initial notice before the welcome screen and must require a fresh acknowledgement when the user starts a new assessment.
- `professional-auth-ui`: The professional app entry flow must present the initial notice after login when the screener has no recorded platform agreement date.
- `screener-authentication`: The authenticated screener contract must expose and persist the platform-wide legal-notice acknowledgement state.
- `screener-user-model`: Screener records must store the platform-wide initial-notice agreement timestamp.
- `database-migration`: Migration scripts must add and backfill the screener legal-notice agreement field without losing existing data.
- `shared-flutter-component-library`: Shared legal footer, legal document viewer, and acknowledgement surfaces must live in `packages/design_system_flutter`.

## Impact
- Affected apps: `apps/survey-patient/`, `apps/survey-frontend/`, `apps/clinical-narrative/`, `apps/survey-builder/`
- Affected shared package: `packages/design_system_flutter/`
- Affected backend and persistence areas: `services/survey-backend/` screener model, repository, and migration scripts
- Affected API/contracts: screener profile and acknowledgement endpoints in `packages/contracts/survey-backend.openapi.yaml` and generated Dart SDKs
- Affected content assets: `docs/legal/Aviso-Inicial-de-Uso-ptbr.md` and `docs/legal/Termo-de-Uso-e-Política-de-Privacidade-ptbr.md`
- Affected UX flows: patient app bootstrap and restart flow, professional post-login gating, and cross-app footer consistency
- Validation impact: Flutter analysis for affected apps, backend compile/migration validation, and generated client review if screener contract fields change
