## Why

The LAPAN Flutter apps currently communicate status, success, warnings, and errors through a fragmented mix of snackbars, inline panels, chips, and custom banners. This inconsistency makes feedback harder to recognize, weakens accessibility, and prevents users from building stable expectations across `survey-patient`, `survey-frontend`, `survey-builder`, and `clinical-narrative`.

This change is needed now because the shared Flutter component library already exists and is mature enough to become the canonical home for a platform-wide feedback system. Standardizing severity, iconography, message structure, and placement rules will improve clarity immediately and create a clean foundation for later work on form guidance, AI waiting states, and emotional microcopy.

## What Changes

- Introduce a new cross-app capability for standardized feedback messaging, covering severity taxonomy, icon mapping, message structure, message placement rules, and accessibility expectations.
- Add canonical shared feedback primitives to `packages/design_system_flutter` for inline messages, banners, summaries, snackbars/toasts, and dialog-level status treatment.
- Update the shared professional auth surfaces so sign-in, sign-up, password recovery, and initial-notice feedback use the same severity-based model instead of binary success/error treatment.
- Update patient survey flows so survey loading, missing-field states, submission feedback, preliminary assessment feedback, and report-state feedback use structured severity-aware messaging.
- Update clinical chat UI requirements so assistant alerts, insight panels, and conversation status surfaces distinguish information type and severity consistently.
- Update survey-builder requirements so administrative save, validation, conflict, delete, and catalog-state feedback is shown in-context and not only through raw snackbars.
- Add final implementation verification so all migrated user-facing Brazilian Portuguese messages are reviewed and corrected for proper accentuation, spelling, and diacritics.

## Capabilities

### New Capabilities
- `shared-feedback-messaging`: Define the platform-wide feedback taxonomy, iconography, message composition model, placement rules, and accessibility expectations for user-facing status communication across LAPAN Flutter apps.

### Modified Capabilities
- `shared-flutter-component-library`: Extend the shared Flutter package requirements so the canonical feedback primitives and their ownership rules live in `packages/design_system_flutter`.
- `professional-auth-ui`: Change the auth UI requirements so professional sign-in and sign-up surfaces expose consistent severity-based loading, validation, success, warning, and error feedback.
- `patient-survey-flow`: Change the patient survey-flow requirements so welcome, demographics, thank-you, and report states use structured feedback containers rather than ad-hoc messaging.
- `clinical-chat-ui`: Change the clinical conversation UI requirements so assistant alerts, status panels, and message-area feedback distinguish severity and information type consistently.
- `frontend-survey-builder`: Change the builder UI requirements so administrative feedback is shown in-context with standardized message severity, actions, and placement rules.

## Impact

- Affected code: `packages/design_system_flutter/`, `apps/survey-patient/`, `apps/survey-frontend/`, `apps/survey-builder/`, `apps/clinical-narrative/`
- Likely shared components: feedback banners, inline messages, error summaries, toast/snackbar adapters, and severity/icon mapping utilities
- UX impact: consistent recognition of information, success, warning, and error states across all Flutter apps
- Accessibility impact: better non-color status recognition and better status-message semantics for assistive technologies
