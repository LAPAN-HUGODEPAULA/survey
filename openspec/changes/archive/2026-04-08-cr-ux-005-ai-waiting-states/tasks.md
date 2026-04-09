## 1. Backend: Contracts and Stage Reporting

- [x] 1.1 Update `clinical-writer-api` to emit stage events based on LangGraph nodes.
- [x] 1.2 Implement polling or streaming support for stages in `survey-backend`.
- [x] 1.3 Update the OpenAPI contract (`survey-backend.openapi.yaml`) to include the AI progress object (`ai_progress`).

## 2. Design System: Components and Microcopy

- [x] 2.1 Implement `DsAIProgressIndicator` as a specialization of vertical `DsStepper` (CR-UX-004) + `DsFeedback` (CR-UX-001).
- [x] 2.2 Add microcopy mapping in pt-BR (labels and reassurance) for the 4 LangGraph stages.
- [x] 2.3 Ensure support for `warning` (retry) and `critical` severity states for AI processing failures.

## 3. Application Implementation

- [x] 3.1 Integrate `DsAIProgressIndicator` into the form cycle (`submitted`) in `survey-patient` and `survey-frontend`.
- [x] 3.2 Update the professional report flow with redirection guidance (Wayfinding CR-UX-004).
- [x] 3.3 Implement the new waiting state in the transcription and analysis flows of `clinical-narrative`.

## 4. Verification

- [x] 4.1 Verify if the stages ("Organizing data", "Analyzing signals", "Writing draft", "Reviewing content") transition correctly.
- [x] 4.2 Validate if the microcopy is in perfect pt-BR with correct accentuation.
- [x] 4.3 Ensure AI errors present the option to try again following the shared feedback model.
