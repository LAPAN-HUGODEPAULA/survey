## Context

`survey-builder` currently opens directly into privileged administration screens without any authentication gate. That was tolerable while the app only edited surveys in a limited environment, but it becomes unacceptable now that the builder is the planned control plane for prompts, persona skills, output profiles, and agent access points.

The platform already has screener registration and password-based authentication. Those credentials should remain the source of identity, but builder access should no longer be tied to a single system screener identifier. Instead, a screener becomes eligible for builder access only when the backend records that screener as a builder administrator.

The target deployment model also matters. `survey-builder` and `survey-backend` will be served under the same public domain behind Traefik. That makes cookie-based builder sessions feasible without introducing separate auth infrastructure, but it also means the change must define cookie settings, session verification rules, logout behavior, and CSRF protection explicitly.

## Goals / Non-Goals

**Goals:**
- Reuse the existing screener account and password model instead of creating a separate admin credential store.
- Restrict builder access to screeners with backend-managed `isBuilderAdmin=true` and fail closed for every other screener.
- Require backend authorization for all builder-managed reads and writes, even if a client bypasses the Flutter route guard.
- Provide builder-specific login behavior that returns an admin-specific error when a valid non-admin screener attempts to sign in.
- Use stateless signed cookies plus CSRF protection for builder sessions without requiring extra infrastructure beyond the current reverse-proxy deployment.
- Add explicit login-required and session-expired states so the builder does not fail silently.
- Support multiple builder administrators now, without shared credentials.

**Non-Goals:**
- Adding role-management UI or in-product administrator management in this change.
- Replacing screener self-registration, password recovery, or other existing professional account workflows.
- Implementing the audit trail itself; this change only ensures that future audit logging can attribute builder actions to an individual admin screener.
- Generalizing this change into a platform-wide role or permission framework.

## Decisions

1. **Use builder-specific authentication endpoints backed by screener credentials**
   `survey-builder` should not call the generic screener login contract directly. Instead, the backend should expose builder-specific auth endpoints that validate screener credentials against the existing screener store, then enforce builder-admin privilege before issuing a builder session. This keeps one source of truth for identity while allowing builder-specific error handling and session policy.

   Alternatives considered:
   - Reuse the generic screener login endpoint unchanged: rejected because builder needs admin-specific login failure behavior without changing normal screener login for other apps.
   - Dedicated builder-only username/password store: rejected because it adds an independent attack surface and more operational overhead.
   - Frontend-only shared-secret gate: rejected because it is insecure and cannot provide user attribution.

2. **Authorize builder access with a backend-managed `isBuilderAdmin` flag**
   Builder access will be allowed only when the authenticated screener record has `isBuilderAdmin=true`. The system screener may be one such account, but builder authorization is not defined by the account's special runtime role. New screener records should default to `false`, and administrator promotion or revocation remains an operational backend concern for now.

   Alternatives considered:
   - Authorize against a configured admin email or screener id: rejected because it hardcodes or externalizes authorization state instead of keeping it with the screener record.
   - Maintain a separate allowlist collection for this change: rejected because a boolean flag is simpler and sufficient while builder functions remain a single privilege class.
   - Allow any screener account: rejected because it violates the administrative access requirement.

3. **Use stateless signed cookies for builder sessions**
   After successful builder login, the backend should issue a signed cookie scoped to builder authentication under the shared public domain. The cookie should identify the screener by stable screener id, not email, and should be validated on every builder request. The builder frontend should not be responsible for storing bearer tokens for this flow.

   Alternatives considered:
   - Store bearer tokens in browser-managed frontend storage: rejected because cookie-based sessions are stronger for this deployment and avoid exposing the builder token directly to application code.
   - Server-stored session records: rejected for now because the user requested no additional infrastructure beyond the current stack.

4. **Require CSRF protection for authenticated builder writes**
   Because builder auth uses cookies, authenticated write operations must enforce CSRF validation. The backend should expose a clear CSRF contract for the builder frontend, and all state-changing builder routes must reject missing or invalid CSRF tokens.

   Alternatives considered:
   - Rely on same-site cookies alone: rejected because the builder performs privileged administrative writes and should defend explicitly against cross-site request forgery.
   - Apply CSRF only to a subset of write routes: rejected because it creates uneven protection and increases the chance of missed coverage.

5. **Gate the entire app behind an authenticated admin shell**
   `survey-builder` should boot into an auth gate that checks the current builder session before rendering any administrative screen. Users without a valid session see the login entry. Expired or invalid sessions return to login with a session-expired message. The design no longer needs a full-screen unauthorized page because non-admin screeners are rejected during builder login instead of being admitted into the shell first.

   Alternatives considered:
   - Guard individual routes only: rejected because the app has a small route graph and a single app-wide gate is simpler and safer.
   - Allow the survey list to render before auth check completes: rejected because it leaks privileged metadata.

6. **Keep auth and authorization logic centralized in backend dependencies**
   The backend should expose a reusable dependency for “authenticated builder session” and a stricter dependency for “builder admin required”. Every builder route should compose the stricter guard instead of duplicating checks per endpoint. This keeps the session verification path, CSRF contract, and admin privilege enforcement consistent.

   Alternatives considered:
   - Per-route inline conditionals: rejected because it invites omissions as the builder surface grows.

## Risks / Trade-offs

- [Risk] A screener could be promoted or revoked manually while an existing builder cookie remains valid. → Mitigation: verify current `isBuilderAdmin` state on every builder request instead of trusting privilege claims embedded only at login time.
- [Risk] Cookie configuration could fail across environments if the reverse-proxy domain, path, or security attributes drift. → Mitigation: document the Traefik deployment assumptions and define explicit cookie settings for local and production environments.
- [Risk] CSRF implementation can become inconsistent if routes are added without the shared guard. → Mitigation: centralize CSRF validation in the same dependency path that protects builder admin routes.
- [Risk] Self-registration plus manual promotion can create operational delays when a new admin needs access. → Mitigation: provide a helper shell script and clear runbook instructions for promote and revoke operations.

## Migration Plan

1. Extend screener records with `isBuilderAdmin=false` by default and manually mark the initial administrators, including the system screener if desired.
2. Introduce builder-specific auth endpoints, signed builder cookies, CSRF support, and backend authorization dependencies.
3. Protect all existing builder-managed backend routes before exposing the new builder login flow.
4. Add the `survey-builder` login entry, session bootstrap, and protected admin shell.
5. Update builder API clients so authenticated requests rely on the builder cookie and CSRF contract instead of frontend-managed bearer tokens.
6. Roll back by disabling builder exposure or clearing admin flags as needed; do not bypass authentication or remove CSRF checks to restore access.

## Open Questions

- Do we want a dedicated builder-session status endpoint for frontend bootstrap, or should the builder shell rely on an existing profile-style endpoint scoped to builder auth?
- Should the helper operational script update screener records directly in MongoDB, or call a future protected maintenance endpoint once one exists?
