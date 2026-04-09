## 1. Design System: AI Visibility Components

- [x] 1.1 Expand `DsAIProgressIndicator` or implement the `DsAssistantStatus` widget to support clinical conversation contexts.
- [x] 1.2 Implement support for "Reassurance" and Wayfinding (CR-UX-004/005) messages in the assistant interface.
- [x] 1.3 Standardize the `DsAIInsightCard` component as a wrapper around `DsFeedbackMessage` with semantic variations (info, warning, success).

## 2. Implementation in Clinical Narrative

- [x] 2.1 Create the `AssistantStatusController` or refactor the `ChatProvider` to expose a consolidated AI visibility state.
- [x] 2.2 Implement the phase mapping logic (Technical -> pt-BR Clinical) in the controller.
- [x] 2.3 Replace fragmented indicators in `ChatPage` with the new `DsAssistantStatus` area.
- [x] 2.4 Refactor the findings/insights panel to use the new `DsAIInsightCard` component integrated with the API (suggestions, alerts, hypotheses).
- [x] 2.5 Implement "Tentar Novamente" and "Cancelar" controls integrated into the AI processing flow (CR-UX-007).

## 3. Verification

- [x] 3.1 Validate if the `intake`, `assessment`, `plan`, and `wrap_up` phases are displayed with their respective humanized names.
- [x] 3.2 Verify the visual consistency of insight cards (color and icon) for suggestions, alerts, and hypotheses.
- [x] 3.3 Test the interface behavior during processing failures (`DsAIProgressIndicator` error state).
- [x] 3.4 Confirm accessibility and live-region semantics for AI state changes (CR-UX-001).
