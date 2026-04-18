# Survey Builder Admin Access Runbook

## Purpose

This runbook explains how to enable, operate, revoke, and recover access to the protected `survey-builder` administrative shell without falling back to shared credentials.

## Deployment assumptions

- `survey-builder` and `survey-backend` are published behind Traefik under the same public domain or subdomain family so the browser can send the builder session cookie on API requests.
- `survey-backend` keeps `allow_credentials=true` and allows the configured builder origin in `CORS_ALLOWED_ORIGINS`.
- Production environments set `ENVIRONMENT=production`, a non-default `SECRET_KEY`, and `BUILDER_COOKIE_DOMAIN` to the public cookie scope expected by Traefik.
- Builder sessions use the `survey_builder_session` cookie by default. Builder writes also require the `survey_builder_csrf` cookie and the matching `X-Builder-CSRF` header.
- The frontend must boot through `GET /api/v1/builder/session` before loading any privileged catalog. The backend remains the source of truth for both authentication and current `isBuilderAdmin` authorization.

## Rollout order

1. Deploy the backend changes that add builder login, cookie validation, CSRF enforcement, and route protection.
2. Promote at least one known screener account with `isBuilderAdmin=true`.
3. Verify the promoted account can log in through `/api/v1/builder/login`, load `/api/v1/builder/session`, and save a protected write with a valid `X-Builder-CSRF` header.
4. Deploy the updated `survey-builder` frontend that boots through the protected admin shell.
5. Expose or announce the builder route only after the previous checks pass.

## Self-register then promote workflow

1. Ask the future administrator to self-register through the normal screener registration flow.
2. Confirm the professional identity and the screener email before granting builder access.
3. Promote the account with the helper script:

```bash
tools/scripts/set_builder_admin.sh --email admin@example.com --enable
```

4. Ask the administrator to open `survey-builder` and sign in with the same screener credentials.
5. When access is no longer needed, revoke it with:

```bash
tools/scripts/set_builder_admin.sh --email admin@example.com --disable
```

## CSRF expectations

- All state-changing builder routes reject requests that do not include both the builder CSRF cookie and the matching `X-Builder-CSRF` header.
- Reads may use the builder session cookie alone, but they still require a valid authenticated admin session.
- A revoked admin keeps no effective access even if an old cookie is still present because the backend rechecks `isBuilderAdmin` on every protected request.

## Emergency access and rollback

- If builder access must be stopped quickly, remove public exposure at Traefik or revoke all builder admins except a controlled break-glass account.
- If a specific administrator account is compromised, revoke it immediately with the helper script and require a fresh login after remediation.
- If a trusted replacement admin is needed, promote a different screener account instead of reusing shared credentials.
- If the frontend rollout must be reversed, keep the backend route protection and CSRF enforcement in place; do not reopen anonymous builder access.
- If operators need to validate recovery, clear the browser cookies for the builder domain or wait for the session cookie to expire, then log in again.

## Never do this

- Do not restore direct anonymous access to `survey-builder`.
- Do not share one screener password across multiple administrators.
- Do not bypass CSRF checks to get writes working temporarily.
- Do not change `isBuilderAdmin` by editing production data manually without recording the operational reason.
