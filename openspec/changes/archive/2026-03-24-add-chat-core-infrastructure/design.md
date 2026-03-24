## Context

This change introduces the foundational chat layer for `clinical-narrative`. It spans frontend state management, backend persistence, and API contracts that will later support voice, AI assistance, and document generation.

## Goals / Non-Goals

- Goals:
- Define a stable session model and lifecycle for consultations.
- Ensure message data is structured, ordered, and recoverable.
- Support turn-based conversational flow and consultation phases.
- Provide input mechanisms consistent with the clinical workflow.
- Non-Goals:
- Implement voice transcription pipelines (covered by a separate capability).
- Implement template rendering or document generation.
- Expand, replace or rewrite the existing `clinical-writer-api` logic.

## Decisions

- Decision: Use session-based persistence with explicit lifecycle states.
- Decision: Store message history with types and metadata to support UI and AI processing.
- Decision: Keep the initial flow turn-based to simplify concurrency and reduce errors.
- Decision: Introduce consultation phases to steer AI behavior and UI context.

## Alternatives Considered

- Alternative: Stateless chat with only frontend storage.
- Rationale: Not acceptable due to recovery and audit needs.
- Alternative: Free-form chat without phases.
- Rationale: Reduces clinical guidance and structured output quality.

## Risks / Trade-offs

- Risk: Added persistence increases complexity for early iterations.
- Mitigation: Minimal fields and simple lifecycle transitions first.
- Risk: Phase handling may be underused by clinicians.
- Mitigation: Allow manual phase selection and AI suggestions.

## Migration Plan

- Introduce session and message endpoints without disrupting the existing prompt-based flow.
- Migrate the UI to use sessions and message history once endpoints are stable.

## Open Questions

- How long should completed sessions be retained by default?
- What is the minimum set of message metadata needed for MVP?
