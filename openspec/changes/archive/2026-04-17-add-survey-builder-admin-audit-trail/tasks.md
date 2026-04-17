## 1. Audit model and storage

- [x] 1.1 Define the persistent builder audit event schema, storage collection or table, and append-only write rules.
- [x] 1.2 Add correlation-id propagation or generation for builder-facing backend requests so audit events can be linked to traces and incident logs.
- [x] 1.3 Define the minimization, redaction, retention, and restricted-access policy for builder audit records.

## 2. Backend instrumentation

- [x] 2.1 Instrument authenticated builder login, logout, authorization-denied, create, update, delete, and publish flows to persist audit events with normalized action and outcome codes.
- [x] 2.2 Ensure builder-managed backend routes emit auditable outcomes for both successful writes and rejected operations.
- [x] 2.3 Add automated tests covering audit persistence, append-only behavior, denied-action auditing, and correlation-id presence.

## 3. Builder integration and operations

- [x] 3.1 Update `apps/survey-builder` so privileged actions complete only through backend-mediated operations that can be audited.
- [x] 3.2 Document how operators retrieve, protect, and review builder audit records for LGPD and incident-investigation workflows.
- [x] 3.3 Validate the final implementation against privacy requirements to confirm no PHI, raw secrets, or full prompt bodies are written into audit storage by default.
