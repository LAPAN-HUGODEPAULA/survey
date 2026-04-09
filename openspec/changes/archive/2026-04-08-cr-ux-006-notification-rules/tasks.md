## 1. Design System: Refactoring and Componentization

- [x] 1.1 Rename `DsFeedbackBanner` to `DsMessageBanner` and maintain a deprecated alias.
- [x] 1.2 Rename `DsInlineFeedback` to `DsInlineMessage` and maintain a deprecated alias.
- [x] 1.3 Formalize the `DsToast` component and the `showDsToast` helper function, replacing direct `SnackBar` usage.
- [x] 1.4 Refactor `DsDialog` to accept `DsStatusType` and apply severity styles (icon + header color).
- [x] 1.5 Update style documentation in the design system (Markdown).

## 2. Pilot Refactoring and Governance

- [x] 2.1 Refactor professional authentication flows to use `DsInlineMessage` (CR-UX-003).
- [x] 2.2 Update save success feedback in `survey-builder` to use `DsToast`.
- [x] 2.3 Implement `DsDialog` with `Warning` severity for draft deletion confirmation in `survey-frontend`.
- [x] 2.4 Validate if Wayfinding messages (CR-UX-004) use `DsMessageBanner`.

## 3. Accessibility and Style Verification

- [x] 3.1 Ensure `DsToast` has correct live-regions for screen readers.
- [x] 3.2 Verify if contrast colors meet WCAG 2.1 for all severity levels.
- [x] 3.3 Validate if dialogs use explicit verbs (e.g., "Delete") instead of generic ones.
- [x] 3.4 Confirm all microcopy is in perfect Brazilian Portuguese (pt-BR) with correct accentuation.
