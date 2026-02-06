## Context
Document generation depends on the chat context, template management, and AI outputs. This change focuses on the workflow to produce final documents with preview, rendering, and export paths.

## Goals / Non-Goals
- Goals:
- Provide a guided document generation flow with preview and confirmation.
- Support PDF export and browser printing with consistent formatting.
- Ensure metadata and compliance requirements are embedded.
- Non-Goals:
- Define template management (handled by template management change).
- Implement advanced digital signatures or external EHR integrations.

## Decisions
- Decision: Use a preview-first flow to allow clinician edits before final output.
- Decision: Treat PDF and print as first-class outputs with defined formatting rules.
- Decision: Store metadata in both document records and output files where applicable.

## Alternatives Considered
- Alternative: Generate PDF only with no preview.
- Rationale: Increases error risk and reduces clinician control.
- Alternative: Generate documents directly from AI text without template rendering.
- Rationale: Reduces consistency and compliance.

## Risks / Trade-offs
- Risk: Rendering complexity across formats.
- Mitigation: Standardize on HTML rendering and derive PDF/print from it.
- Risk: Latency for large documents.
- Mitigation: Cache rendered previews and reuse for export.

## Migration Plan
- Introduce generation endpoints and preview rendering behind feature flags.
- Enable export once preview flow is validated.

## Open Questions
- What is the minimum set of required document metadata for compliance?
- Which PDF library will be used in the first implementation?
