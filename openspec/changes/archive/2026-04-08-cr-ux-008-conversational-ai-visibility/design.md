## Context

Currently, the `clinical-narrative` application has rich states (voice, transcription, analysis), but the interface reflects these states in a fragmented way. The "Fase da IA" label is technically correct but not clinician-friendly. Furthermore, the insight panels do not follow a visual standard that communicates severity or type of information.

## Goals / Non-Goals

**Goals:**
- Centralize AI status in a single "Estado do Assistente" area.
- Humanize LangGraph phase labels into clinical terms in pt-BR.
- Standardize insight cards with icons and severity colors (CR-UX-001).
- Provide cancellation and retry controls (CR-UX-007).

**Non-Goals:**
- Change the AI engine or the LangGraph flow in the backend.
- Implement new types of clinical analysis.

## Decisions

### 1. New Component: `DsAssistantStatus`
- **Rationale**: Unifying state communication reduces the clinician's cognitive load. Uses the `DsStepper` (CR-UX-004) and `DsAIProgressIndicator` (CR-UX-005) patterns.
- **Implementation**: Widget integrated into the `DsScaffold` or positioned above the chat entry that displays:
  - Vertical/horizontal stepper with mapped phases.
  - "Reassurance" messages via `DsFeedback` (CR-UX-005).
  - Interruption actions (Cancelar/Tentar Novamente).

### 2. Phase Mapping (Translation Layer)
- **Rationale**: Translate technical jargon into clinical terminology in pt-BR.
- **Mapping**:
  - `intake` -> "Anamnese" (Collecting basic information)
  - `assessment` -> "Avaliação Clínica" (Analyzing signs and symptoms)
  - `plan` -> "Planejamento" (Structuring conducts and hypotheses)
  - `wrap_up` -> "Encerramento" (Finalizing records)

### 3. Insight Standardization: `DsAIInsightCard`
- **Rationale**: Insights need to be semantically categorized (CR-UX-001/006).
- **Implementation**: Uses `DsFeedbackMessage` with variations:
  - `Suggestions/Facts` -> `DsStatusType.info` (Blue, Icon: `lightbulb`)
  - `Hypotheses/Alerts` -> `DsStatusType.warning` (Amber, Icon: `psychology` or `warning`)
  - `Confirmed/Final` -> `DsStatusType.success` (Green, Icon: `check_circle`)

### 4. Assistant Controller (`AssistantStatusController`)
- **Rationale**: Facilitate synchronization between voice and analysis streams.
- **Implementation**: In `clinical-narrative`, centralize the `isProcessing` state, `currentPhase`, and the list of `insights` (suggestions, alerts, hypotheses) in a reactive controller.

## Risks / Trade-offs

- **[Risk]** Excessive visual information in the chat area. → **Mitigation**: The `DsAssistantStatus` component SHALL be collapsible, showing only the current phase and a simplified progress indicator when not expanded.
- **[Trade-off]** Static phase mapping. → **Mitigation**: The mapping SHALL be configurable via `metadata` or centralized in the `ChatProvider` for easy maintenance if the graph changes.
