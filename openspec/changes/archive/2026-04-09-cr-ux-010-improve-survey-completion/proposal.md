## Why

The transition from answering questions to receiving guidance or reports is one of the most emotionally charged parts of the platform. Currently, submission success, AI processing, and final reports are often combined into a single, confusing visual block. Improving this handoff will reduce user anxiety, provide clearer orientation, and ensure users understand the status of their data and the availability of their results.

## What Changes

- **Visual Separation of Stages**: Implementation of a distinct three-step handoff model: "Responses Registered" -> "Analysis in Progress" -> "Report Ready".
- **Enhanced Progress Visibility**: Explicitly separating data persistence success from AI generation status.
- **Protocol/Reference ID Context**: Reference IDs will only be shown after a plain-language explanation of their meaning and use.
- **Supportive Completion Language**: Implementation of empathetic microcopy that acknowledges user effort and contribution.
- **Distinct Visual Containers**: System-state messages (e.g., "Saving...") will be visually separated from clinical/informational notes.
- **Optional Enrichment Forks**: Clearer guidance for optional demographic or clinical enrichment steps, explaining benefits and non-benefits.

## Capabilities

### New Capabilities
- `survey-completion-handoff`: Defines the standard three-step handoff model and visual separation rules for survey completion.

### Modified Capabilities
- `patient-assessment-summary`: Update requirements to include stage-based rendering and visual separation of system status from clinical content.
- `patient-survey-flow`: Modification of the final stages of the flow to support the multi-step completion sequence.
- `shared-feedback-messaging`: Expansion of message types to include specific "effort acknowledgement" and "handoff orientation" patterns.

## Impact

- `packages/design_system_flutter`: New components or updates to `DsFeedback` and `DsScaffold` to support distinct completion containers and handoff states.
- `apps/survey-patient`: Redesign of the post-submission journey for patients.
- `apps/survey-frontend`: Improved professional assessment completion and report-generation visibility.
