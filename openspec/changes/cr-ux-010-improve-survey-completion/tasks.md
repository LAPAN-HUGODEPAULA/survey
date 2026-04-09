## 1. Design System Enhancements

- [x] 1.1 Create `DsClinicalContentCard` in `packages/design_system_flutter` with a distinct visual style for clinical findings.
- [x] 1.2 Define handoff-specific microcopy (pt-BR) and stage labels for Steps 1, 2, and 3.
- [x] 1.3 Add a generic "Handoff Fork" component to `DsScaffold` or shared widgets to support optional enrichment paths.

## 2. Patient App Completion Handoff

- [x] 2.1 Refactor `ThankYouScreen` in `survey-patient` to use a `HandoffState` enum.
- [x] 2.2 Implement Step 1 (Responses Registered): Show empathetic acknowledgment and the reference ID with context.
- [x] 2.3 Implement Step 2 (Analysis in Progress): Render the `DsStatusIndicator` with the analysis stage label.
- [x] 2.4 Implement Step 3 (Report Ready): Transition to the `DsClinicalContentCard` for the AI summary.
- [x] 2.5 Update the demographics screen in `survey-patient` with the optional enrichment guidance.

## 3. Professional App & Verification

- [x] 3.1 Apply the same handoff model and visual separation to assessment completion in `survey-frontend`.
- [x] 3.2 Add widget tests for the `ThankYouScreen` handoff sequence.
- [x] 3.3 Verify that the reference ID only appears after the successful registration step.
- [x] 3.4 Review all microcopy in `pt-BR` for naturalness and supportive tone.
