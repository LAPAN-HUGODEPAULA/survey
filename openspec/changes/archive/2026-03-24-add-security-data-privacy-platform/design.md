## Context
The platform spans multiple services and Flutter apps. Security and privacy expectations are currently implicit and unevenly captured in specs. This change establishes explicit, platform-wide requirements without prescribing specific technologies or retention durations.

## Goals / Non-Goals
- Goals:
  - Provide a single source of truth for LGPD-aligned privacy governance.
  - Require consistent access control, encryption, and auditability across services.
  - Define data lifecycle and deletion behavior without fixed retention periods.
- Non-Goals:
  - Implement specific cryptographic libraries or MFA flows.
  - Define concrete retention durations or legal counsel decisions.

## Decisions
- Decision: Introduce five focused capabilities instead of one monolithic spec.
  - Rationale: Keeps requirements readable, allows incremental implementation, and aligns with OpenSpec guidance for single-purpose capabilities.
- Decision: Avoid specifying concrete retention durations and MFA.
  - Rationale: The user requested no retention periods and MFA is not required for this proposal.

## Risks / Trade-offs
- Risk: Requirements may be too high-level for immediate implementation.
  - Mitigation: Add testable scenarios and tasks that translate requirements into verifiable work items.
- Risk: Platform-wide scope increases coordination cost.
  - Mitigation: Split into capabilities and sequence tasks to allow parallel work.

## Migration Plan
1. Align backend auth, authorization, and logging behavior with new specs.
2. Update frontend apps to reflect privacy-by-default UX and access rules.
3. Add data lifecycle workflows and consent handling in the backend.
4. Validate compliance with security and privacy tests.

## Open Questions
- Which internal owner approves LGPD legal-basis documentation and DPIA records?
- What are the preferred alert delivery channels for security monitoring (email, chat, dashboard)?
