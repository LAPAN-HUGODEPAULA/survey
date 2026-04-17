## 1. Authentication and authorization foundation

- [x] 1.1 Extend the screener data model and persistence layer so screener records store `isBuilderAdmin`, defaulting to `false` for non-admin accounts.
- [x] 1.2 Add reusable backend dependencies for authenticated builder sessions and builder-admin authorization backed by current screener data.
- [x] 1.3 Extend all builder-facing backend routes, including read-only catalog and export routes, so every privileged request requires the builder-admin authorization dependency.

## 2. Survey-builder login flow

- [x] 2.1 Add builder-specific backend auth endpoints that validate screener credentials, reject non-admin screeners with an admin-specific login error, and issue stateless signed builder session cookies for successful admins.
- [x] 2.2 Add backend CSRF issuance and validation for authenticated builder write operations.
- [x] 2.3 Implement the `survey-builder` login entry, session bootstrap, logout flow, and session-expired recovery using the builder cookie and CSRF contract instead of frontend-managed bearer tokens.

## 3. Integration hardening

- [x] 3.1 Update builder API clients and request plumbing so authenticated reads and writes use the builder session cookie automatically and attach CSRF headers where required.
- [x] 3.2 Add backend and Flutter tests covering unauthenticated access, non-admin login denial, successful admin login, revoked-admin access denial, CSRF enforcement, logout, and expired-session recovery.
- [x] 3.3 Document the Traefik same-domain deployment assumptions, cookie security settings, CSRF expectations, and rollout order for enabling the protected builder shell.

## 4. Administrator operations

- [x] 4.1 Document the self-register then promote workflow for new builder administrators.
- [x] 4.2 Add a shell script or equivalent operational helper to set or revoke `isBuilderAdmin` for a screener record.
- [x] 4.3 Document rollback and emergency access procedures that preserve authentication and authorization guarantees without reverting to shared credentials.
