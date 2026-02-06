## Context
This change introduces AI-driven conversation assistance layered on top of the chat core. It spans AI services, data enrichment, and UI delivery of suggestions, alerts, and context summaries.

## Goals / Non-Goals
- Goals:
- Provide suggestions for missing clinical information and follow-up questions.
- Extract and maintain clinical entities and consultation phase context.
- Detect clinical alerts and surface them with severity.
- Normalize medical terminology and handle negations and temporal relations.
- Non-Goals:
- Replace clinician judgment or automate final decisions.
- Deliver full document generation or template rendering.

## Decisions
- Decision: Keep AI outputs as recommendations with explicit clinician control.
- Decision: Maintain structured outputs for suggestions, entities, and alerts.
- Decision: Prioritize minimal, explainable signals over opaque reasoning.

## Alternatives Considered
- Alternative: Single monolithic AI response without structured outputs.
- Rationale: Hard to validate and difficult to integrate into UI safely.
- Alternative: Rule-based only approach.
- Rationale: Insufficient coverage for complex clinical language.

## Risks / Trade-offs
- Risk: False positives in alerts and suggestions.
- Mitigation: Severity levels, clinician override, and logging for tuning.
- Risk: Latency from multi-step processing.
- Mitigation: Parallelizable extraction and cached knowledge lookups.

## Migration Plan
- Introduce analysis endpoints and structured outputs without changing current UI.
- Add UI integration for suggestions and alerts after endpoints stabilize.

## Open Questions
- Which knowledge sources will be used initially for codes and interactions?
- What minimum accuracy thresholds are required before production rollout?
