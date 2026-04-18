## Why

The `survey-builder` currently opens directly into administrative survey management without authentication, which creates an obvious access-control gap. That was already unsafe when the app only managed surveys, and it becomes more serious as the builder expands into prompts, personas, output profiles, and future access-point governance.

The earlier proposal tied builder access to the platform's default system screener identity. That is no longer the right model. The platform needs separate administrator accounts with individual credentials, explicit privilege assignment, and a path to audit who changed what. The system screener may be one administrator, but builder authorization must be defined by backend-managed admin privilege, not by a single hardcoded or environment-configured identity.

## What Changes

- Add a dedicated `survey-builder` authentication flow backed by the existing screener credential store, but exposed through builder-specific login and logout endpoints.
- Introduce a backend-managed `isBuilderAdmin` privilege on screener records, defaulting to `false`, and require that privilege for every `survey-builder` route, including read-only catalog and export operations.
- Issue stateless signed builder session cookies and enforce CSRF protection for authenticated builder operations under the shared public domain served through the reverse proxy.
- Return an admin-specific login error when valid screener credentials are supplied for a non-admin screener account.
- Add clear login-required and session-expired states for the builder UI so expired or invalid sessions recover cleanly without exposing administrative data.
- Document and support the operational workflow for promoting and revoking builder administrators through manual database updates, including an optional helper shell script.

## Capabilities

### New Capabilities
- `builder-admin-access-control`: Admin-only session and authorization rules for `survey-builder`.

### Modified Capabilities
- `screener-authentication`: Reuse screener credentials and identity records for builder-specific admin authentication.
- `access-control-security`: Extend authorization requirements to the `survey-builder` admin surface.
- `frontend-survey-builder`: Replace direct application entry with an authenticated admin shell.

## Impact

- Affected apps: `apps/survey-builder`
- Affected backend areas: screener auth, builder session handling, CSRF enforcement, admin authorization checks for builder-managed APIs
- Affected data model: screener records gain backend-managed builder-admin privilege state
- Affected docs: admin access policy, reverse-proxy deployment guidance, and operational promotion or revocation instructions
- Dependencies: existing screener credential validation, same-domain reverse-proxy routing, future audit logging change
