# Change: Clinical Narrative Template Management

## Why
Clinical documents need consistent, editable templates that can be governed and reused across consultations. A centralized template system with versioning and approvals is required before reliable document generation can be delivered.

## What Changes
- Define supported document types and ownership rules.
- Introduce template lifecycle with versioning, draft/active states, and approvals.
- Specify template structure with placeholders and conditional sections.
- Provide template discovery and selection for clinicians.
- Enforce access control and auditability for template changes.

## Impact
- Affected specs: `template-types`, `template-lifecycle`, `template-structure`, `template-selection`, `template-security`.
- Affected code: `services/survey-backend/`, `services/clinical-writer-api/`, `apps/clinical-narrative/`, `packages/contracts/`.
- Parent change: `add-clinical-narrative-overview`.
