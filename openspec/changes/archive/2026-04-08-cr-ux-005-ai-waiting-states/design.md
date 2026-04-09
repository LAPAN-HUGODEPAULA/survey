## Context

Currently, the LAPAN Survey Platform uses `DsLoading` for AI operations. AI response times can exceed 10 seconds, which generates anxiety without stage-based feedback. The AI execution graph (LangGraph) has 4 logical stages (ContextLoader, ClinicalAnalyzer, PersonaWriter, ReflectorNode) that must be visually exposed following the CR-UX-001/003/004 standards.

## Goals / Non-Goals

**Goals:**
- Integrate AI waiting states into the form submission cycle (CR-UX-003).
- Use `DsStepper` (CR-UX-004) for visualization of LangGraph stages.
- Use `DsFeedback` (CR-UX-001) for error handling and reassurance.
- Create an observable API contract for state reporting.

**Non-Goals:**
- Implement real-time text streaming.
- Change the clinical logic of the agents.

## Decisions

### 1. New Component: `DsAIProgressIndicator` (Hybrid)
- **Rationale**: Evolution of `DsLoading` into something that communicates real progress and value.
- **Implementation**: A container that integrates a vertical `DsStepper` (for the 4 LangGraph stages) and a dynamic content area based on the `DsFeedback` model.

### 2. LangGraph → UI Mapping
- **Stage 1: ContextLoader** → "Organizing the history": "We are gathering the questionnaire responses and clinical instructions for the case."
- **Stage 2: ClinicalAnalyzer** → "Analyzing clinical signs": "We are analyzing the main signs of the case for a more careful initial reading."
- **Stage 3: PersonaWriter** → "Writing draft": "We are writing the first version of the document with the appropriate tone for the target audience."
- **Stage 4: ReflectorNode** → "Reviewing consistency": "We are reviewing the content to ensure the information is clear and reliable."

### 3. Form Lifecycle Integration (CR-UX-003)
- **Flow**: `submitted` (Backend receives) → `processing` (Frontend polling LangGraph stages) → `success` (Result display).
- **Redirection**: If the AI takes too long, the system should provide visual redirection guidance (e.g., "We are preparing your report. You can wait here or review the answers below.") following CR-UX-004.

### 4. Error Handling via `DsFeedback` (CR-UX-001)
- **Recoverable (Warning)**: "We had a delay in the analysis, we are trying again..." + Option to "Try Manually".
- **Critical (Error/Critical)**: "It was not possible to automatically generate the report at this time." + Option to export raw answers.

## Risks / Trade-offs

- **[Risk]** Excessive exposure of LangGraph technical details. → **Mitigation**: Technical node names will be mapped to clinical human language ("PersonaWriter" → "Writing draft").
- **[Trade-off]** Polling vs WebSocket. → **Mitigation**: Initially short polling (1-2s) to maintain infrastructure simplicity, as graphs take between 5 and 20 seconds.
