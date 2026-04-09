## Why

Currently, the `clinical-narrative` application presents AI states (session, voice, analysis) in a fragmented way through various chips and indicators, using technical labels such as `analysisPhase=intake`. This makes it difficult for users to understand what the system is doing at any given moment and reduces the perception of control over the clinical conversation flow.

Furthermore, generated insights (suggestions, alerts, hypotheses) lack a standardized visual presentation, either blending into the chat flow or being displayed in generic panels without clear semantic distinction.

## What Changes

- **Unified Assistant Status Area (DsAssistantStatus):** Replaces fragmented indicators with a single "Assistant Status" area that utilizes the Stepper (CR-UX-004) and Reassurance (CR-UX-005) patterns.
- **Humanized Language Mapping (pt-BR):** Implements a translation layer to convert internal graph phases (e.g., `intake`, `assessment`, `plan`) into friendly clinical terms in Brazilian Portuguese: "Anamnese", "Avaliação Clínica", "Planejamento".
- **Standardized Insight Cards:** Employs the `DsFeedbackMessage` system (CR-UX-001) to display AI findings, ensuring consistency in severity (`info` for facts/suggestions, `warning` for hypotheses/alerts).
- **Explicit Flow Controls:** Integrates "Retry", "Cancel", or "Continue Manually" actions directly into the processing states (CR-UX-007).
- **DsScaffold Integration:** Strategically positions AI visibility within the layout, ensuring the user always knows what the assistant is processing without losing the conversation context.

## Capabilities

### New Capabilities
- `conversational-ai-state-visibility`: Defines the unified visibility model for the AI assistant, including the translation of logical phases into human-friendly terms.
- `ai-insight-panel-standard`: Defines the visual and semantic standards for displaying AI-generated insights (Suggestions, Alerts, Hypotheses) using the `DsFeedback` framework.

### Modified Capabilities
- `clinical-chat-ui`: Updates the chat interface to integrate the new status area and standardized insight cards.
- `clinical-session-ui`: Updates the session interface to adopt the new visibility and control standards.
- `shared-flutter-component-library`: Expands `DsAIProgressIndicator` to support conversational contexts beyond report generation.

## Impact

- `packages/design_system_flutter`: Updates to `DsAIProgressIndicator` and creation of AI-focused `DsFeedbackMessage` presets.
- `apps/clinical-narrative`: Refactoring of `ChatPage` and `ClinicalPage` to adopt the new visibility architecture.
