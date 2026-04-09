## 1. Shared Feedback Foundation

- [x] 1.1 Define the canonical shared feedback message model and severity-to-icon mapping in `packages/design_system_flutter`
- [x] 1.2 Implement shared feedback primitives for inline messages, persistent banners, and validation summaries in `packages/design_system_flutter`
- [x] 1.3 Implement or adapt a shared transient feedback presenter/content pattern for snackbar or toast use cases
- [x] 1.4 Add accessibility semantics for nonblocking status announcements in the shared feedback primitives

## 2. Professional Auth Migration

- [x] 2.1 Replace the binary `_DsFeedbackBanner` behavior in shared professional auth widgets with the canonical severity-based feedback surface
- [x] 2.2 Update professional auth flows in `survey-frontend` to drive the shared feedback model for validation, loading, success, warning, and error states
- [x] 2.3 Update professional auth flows in `clinical-narrative` to drive the shared feedback model for validation, loading, success, warning, and error states

## 3. Patient and Assessment Flow Migration

- [x] 3.1 Update `survey-patient` demographics, thank-you, and report surfaces to use structured feedback containers where this change applies
- [x] 3.2 Update `survey-frontend` assessment, access-link, settings, and submission-feedback surfaces to use structured feedback containers where this change applies
- [x] 3.3 Ensure patient and assessment validation states are shown in context and not only through raw snackbars

## 4. Clinical and Builder Feedback Migration

- [x] 4.1 Update `clinical-narrative` assistant alerts, status panels, and other nonblocking conversation feedback to use the canonical shared feedback model
- [x] 4.2 Update `survey-builder` save, delete, export, validation, conflict, loading, and empty-state feedback to use standardized in-context messaging
- [x] 4.3 Remove or deprecate ad-hoc feedback patterns that duplicate the new shared behavior in the migrated surfaces

## 5. Verification and Documentation

- [x] 5.1 Add or update widget tests for shared feedback severity rendering, icon mapping, and accessibility semantics
- [x] 5.2 Verify the migrated apps preserve consistent severity meaning and container choice across the targeted flows
- [x] 5.3 Update developer-facing documentation to describe the shared feedback model, approved placement rules, and deprecated ad-hoc patterns
- [x] 5.4 Perform a final audit of all migrated user-facing messages to correct Brazilian Portuguese accentuation, spelling, and diacritics before completion
