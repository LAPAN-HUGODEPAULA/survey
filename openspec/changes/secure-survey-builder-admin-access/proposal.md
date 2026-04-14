## Why

The `survey-builder` currently opens directly into administrative survey management without authentication, which creates an obvious access-control gap. Because this application will become the control plane for prompts, skills, and agent configuration, it must be restricted to the platform's default system screener before broader rollout.

## What Changes

- Add a dedicated `survey-builder` login flow that uses the existing screener authentication contract.
- Restrict `survey-builder` access so only the platform default system screener can establish an admin session.
- Gate all admin routes in `survey-builder` behind authenticated session checks and explicit backend authorization.
- Add clear unauthorized and session-expired states for the builder UI.
- Prevent anonymous or non-admin screener access to prompt, persona, survey, and future access-point management actions.

## Capabilities

### New Capabilities
- `builder-admin-access-control`: Admin-only session and authorization rules for `survey-builder`.

### Modified Capabilities
- `screener-authentication`: Reuse screener login and profile resolution for builder admin sessions.
- `access-control-security`: Extend authorization requirements to the `survey-builder` admin surface.
- `frontend-survey-builder`: Replace direct application entry with an authenticated admin shell.

## Impact

- Affected apps: `apps/survey-builder`
- Affected backend areas: screener auth, admin authorization checks for builder-managed APIs
- Affected docs: admin access policy and operational setup instructions
- Dependencies: existing screener JWT flow, system screener identity, future audit logging change
