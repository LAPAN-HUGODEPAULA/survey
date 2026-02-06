## Context
Template management spans admin workflows, persistence, and rendering needs for `clinical-narrative`. It must be governed (versioning, approvals) and compatible with later document generation capabilities.

## Goals / Non-Goals
- Goals:
- Provide a governed template repository with lifecycle controls.
- Define template structure to support placeholders and conditional sections.
- Allow clinicians to discover and select approved templates.
- Ensure access control and auditability for template operations.
- Non-Goals:
- Implement PDF rendering or full document generation (separate capability).
- Introduce external template marketplaces or third-party integrations.

## Decisions
- Decision: Use explicit document types as first-class metadata for filtering.
- Decision: Enforce admin-only creation and editing with approval gates.
- Decision: Keep template schema minimal but extensible with placeholders and conditions.

## Alternatives Considered
- Alternative: Store templates as free-form text without schema.
- Rationale: Hard to validate and render consistently.
- Alternative: Allow clinicians to edit templates directly.
- Rationale: Increases governance and compliance risk.

## Risks / Trade-offs
- Risk: Approval workflow may slow iteration.
- Mitigation: Support drafts and fast approval paths for minor edits.
- Risk: Schema over-constraint reduces flexibility.
- Mitigation: Allow optional fields and conditional sections.

## Migration Plan
- Introduce template storage and admin workflows first.
- Add selection UI for clinicians after templates are active.

## Open Questions
- What is the minimum metadata required for template discovery?
- Should archival be allowed when a template was used previously?
