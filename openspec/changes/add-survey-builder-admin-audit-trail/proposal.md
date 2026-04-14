## Why

The `survey-builder` is becoming the central administrative surface for prompt and survey governance, which means its actions must be traceable for security, debugging, and LGPD compliance. Today there is no dedicated persistent audit trail for builder-originated admin actions.

## What Changes

- Add persistent audit logging for all privileged `survey-builder` actions.
- Record create, update, delete, publish, login, logout, authorization failure, and configuration-change events.
- Store actor identity, timestamp, action, target resource, request correlation id, and success or failure outcome.
- Define data-minimization rules so builder audit events do not persist PHI or raw prompt drafts beyond what is required for governance.
- Add retrieval and retention guidance for secure storage and incident investigation.

## Capabilities

### New Capabilities
- `builder-admin-audit-events`: Persistent audit model and event taxonomy for `survey-builder` administration.

### Modified Capabilities
- `audit-logging-monitoring`: Extend the platform audit trail to include builder-originated administrative actions.
- `data-privacy-governance`: Define LGPD-aligned retention, minimization, and access rules for builder audit data.
- `frontend-survey-builder`: Ensure privileged UI actions emit backend-audited operations rather than local-only state changes.

## Impact

- Affected apps: `apps/survey-builder`
- Affected backend areas: audit repositories, admin routes, security logging
- Affected storage: new or expanded persistent audit collection
- Dependencies: authenticated builder sessions, correlation ids, secure audit access policy
