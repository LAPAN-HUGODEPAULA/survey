## Why

Currently, long-running AI operations (report generation, clinical narrative analysis, transcription) use generic waiting states like "Processing..." or "Generating report...". This creates anxiety, uncertainty about progress, and risk of user abandonment, as users do not know if the system is stuck or at what stage the task currently is.

With the consolidation of **Shared Feedback Messaging (CR-UX-001)**, **Form Standardization (CR-UX-003)**, and **Progress Wayfinding (CR-UX-004)** standards, it is necessary for AI waiting states to integrate into this visual and behavioral language, utilizing the LangGraph stages model to provide transparency and reassurance.

## What Changes

- **Form Lifecycle Integration**: Smooth transition from the form `submitted` state (CR-UX-003) to AI processing, using redirection guidance (CR-UX-004).
- **Stage Visualization via Stepper**: Redesign of AI waiting states to use the `DsStepper` component (or similar) mapping the real LangGraph stages (ContextLoader, ClinicalAnalyzer, PersonaWriter, ReflectorNode).
- **Reassurance Microcopy**: Implementation of messages focused on reassuring the user and explaining the value of the wait at each stage of the clinical analysis.
- **Standardized Error Feedback**: Use of `DsFeedback` (CR-UX-001) for AI failures, distinguishing severities (warning for retry, critical for model failure).
- **Observable API Contract**: Evolution of API contracts so that the `clinical-writer-api` reports state changes in the execution graph to the frontend.

## Capabilities

### New Capabilities
- `ai-wait-experience`: Defines the visual and textual interaction standard for AI waits, integrating `DsStepper` and `DsFeedback`.
- `ai-progress-api-contract`: Technical requirements for reporting LangGraph stages (ContextLoader → ClinicalAnalyzer → PersonaWriter → ReflectorNode).

### Modified Capabilities
- `shared-feedback-messaging`: Extension to support "partial processing" or "intelligent retry" states.
- `multi-step-progress-standard`: Application of progress indicators for asynchronous AI flows.

## Impact

- `packages/design_system_flutter`: Implementation of `DsAIProgressIndicator` as a specialization of `DsStepper` + `DsFeedback`.
- `apps/clinical-narrative`: Improvement in chat analysis and document generation flows with AI graph visibility.
- `services/clinical-writer-api`: Exposure of LangGraph stages via events or polling status.
- `services/survey-backend`: Proxying of progress states to the frontend applications.
