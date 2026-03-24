## Context
The evolution of `clinical-narrative` spans the Flutter frontend, FastAPI services, integration with `clinical-writer-api`, and MongoDB persistence. The scope is cross-cutting (UI, voice, AI, documents, and security), requiring architectural alignment before implementation.

## Goals / Non-Goals
- Goals:
- Provide a consistent foundation for clinical conversations with history and context.
- Add voice input with reliable transcription and a simple clinical flow.
- Enable clinical document generation from conversational context.
- Ensure LGPD compliance, auditability, and protection of sensitive data.
- Non-Goals:
- Fully replace the existing `clinical-writer-api`.
- Implement unconfirmed external integrations (e.g., EHRs).

## Decisions
- Decision: Use a persisted conversational session approach with minimal metadata.
- Decision: Adopt hybrid transcription (browser preview + final server processing).
- Decision: Separate templates and document generation into distinct capabilities for independent evolution.
- Decision: Centralize privacy and audit rules as a cross-cutting requirement.

## Alternatives Considered
- Alternative: Server-only transcription.
- Rationale: Less responsive for clinicians during visits.
- Alternative: Hardcoded templates in the frontend.
- Rationale: Makes maintenance and governance harder.

## Risks / Trade-offs
- Risk: Higher complexity in the audio flow and latency.
- Mitigation: Hybrid flow and graceful degradation to text.
- Risk: Scope expansion before clinical validation.
- Mitigation: Incremental implementation guided by small tasks.

## Migration Plan
- Introduce capabilities in phases while keeping the current flow functional.
- Evolve contracts and generated clients only after deltas are approved.

## Open Questions
- Which transcription provider will be adopted initially?
- Which document types are the MVP priorities?
