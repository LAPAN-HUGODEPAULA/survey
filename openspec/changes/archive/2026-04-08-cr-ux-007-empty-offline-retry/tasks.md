## 1. Setup & Design System

- [x] 1.1 Add `connectivity_plus` to `packages/design_system_flutter` dependencies.
- [x] 1.2 Implement `DsEmptyState` widget with support for visual, title, description, and primary action (Wayfinding).
- [x] 1.3 Implement `DsErrorMapper` utility to translate technical exceptions into user-friendly pt-BR messages.
- [x] 1.4 Update `DsFeedbackMessage` to support optional `onRetry` callback and display the "Tentar Novamente" (Retry) button.
- [x] 1.5 Implement the Offline Banner using `DsMessageBanner` (CR-UX-006) and integrate it into `DsScaffold` via connectivity stream.

## 2. Pilot Implementation

- [x] 2.1 Update the questionnaire catalog in `survey-frontend` to use `DsEmptyState` and friendly error messages via `DsErrorMapper`.
- [x] 2.2 Update the screeners (professional) list to use the new empty state standard.
- [x] 2.3 Implement the "Tentar Novamente" button for initial survey loading in case of network failure.

## 3. Verification

- [x] 3.1 Verify that the empty state displays the pt-BR explanation and the suggested action button.
- [x] 3.2 Validate that the offline banner appears automatically upon network disconnection (Warning severity).
- [x] 3.3 Ensure technical errors (e.g., 500 or Timeout) are displayed as friendly pt-BR messages with the "Tentar Novamente" option.
- [x] 3.4 Confirm all new pt-BR microcopy uses correct accentuation and follows project standards.
