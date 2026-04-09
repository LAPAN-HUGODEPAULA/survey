## Context

The survey completion process is a high-anxiety moment. Currently, the `survey-patient` and `survey-frontend` apps show a single "Thank You" screen where several asynchronous events (saving, AI analysis, report rendering) happen in the same space. This design introduces a structured handoff model to manage this transition gracefully.

## Goals / Non-Goals

**Goals:**
- Implement the "Ambient Empathy" (CR-UX-009) principles in the completion handoff.
- Create a state-driven UI sequence for survey completion: `saved` -> `analyzing` -> `ready`.
- Visually separate functional system feedback from clinical content.
- Standardize the presentation of reference IDs with plain-language context.

**Non-Goals:**
- Changes to the backend `create_survey_response` endpoint logic.
- Modification of the AI agent's internal analysis logic (only its presentation status).
- Redesign of the entire report page (focus only on the handoff/summary).

## Decisions

### 1. State-Driven Handoff Controller
- **Rationale**: Managing Step 1, 2, and 3 requires a clean state machine in the UI to avoid "flash of unstyled content" or overlapping messages.
- **Implementation**: Use a local `HandoffState` enum (`registering`, `registered`, `analyzing`, `ready`) in the summary screen.
- **Alternative**: Showing all states at once with visibility flags (rejected: too much visual noise).

### 2. "Status vs. Content" Visual Containers
- **Rationale**: Users should instantly distinguish between "The system is working" and "Here are your clinical results."
- **Implementation**: 
  - **Status Container**: Uses standard `DsFeedback` or `DsStatusIndicator` with a neutral/system background.
  - **Content Container**: Uses a new `DsClinicalContentCard` with a distinct background (e.g., white or a very light soft tone) and refined typography to indicate "This is the final result."

### 3. Progressive Disclosure of Reference IDs
- **Rationale**: A raw UUID or ID string is intimidating without context.
- **Implementation**: The ID is only rendered *after* a successful `registered` state is reached and is preceded by an explanatory text block.

### 4. Optional Enrichment "Handoff Fork"
- **Rationale**: Forcing users into demographics after a long survey can lead to drop-offs.
- **Implementation**: Implement a clear "What's Next?" section with two distinct paths: "Finalize & View Report" vs. "Add Info for Better Insights."

## Risks / Trade-offs

- **[Risk]** The handoff sequence feels slow if the AI is fast. → **Mitigation**: Use smooth, short transitions (300-500ms) even if states change quickly to ensure the user perceives the sequence without feeling blocked.
- **[Trade-off]** Increased complexity in the `ThankYouScreen` logic. → **Mitigation**: Encapsulate handoff logic into a dedicated `SurveyHandoffManager` or similar widget.
- **[Risk]** Inconsistent language in pt-BR. → **Mitigation**: Use the centralized `DsToneTokens` (CR-UX-009) to ensure the handoff microcopy matches the app's tone.
