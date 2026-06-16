# Runtime Config

## Purpose

- `config/runtime/config.private.json` is the source-of-truth for deployment/runtime configuration.
- It is intentionally gitignored because it contains secrets.
- Flutter web apps now read a public `config.json` at runtime, so changing API endpoints no longer requires rebuilding Flutter bundles.

## Files

- Template: `config/runtime/config.private.example.json`
- Real local/VPS file: `config/runtime/config.private.json`
- Generated public app configs: `config/runtime/generated/public/*.config.json`
- Generated private service env files: `config/runtime/generated/private/*.env`

## Security Model

- Do not expose MongoDB, SMTP, JWT, or other secrets in a web-served `config.json`.
- The private JSON is rendered into:
  - public app config files with safe values only, such as `apiBaseUrl` and `viaCepBaseUrl`
  - private env files for Docker services such as MongoDB, `survey-backend`, `survey-worker`, and Traefik
- All Python services use `pydantic-settings` (`BaseSettings`) to load configuration from environment variables rendered by the private JSON. Type validation and startup checks prevent services from starting with missing or insecure values in production mode.

## Startup Validation

In production (`ENVIRONMENT=production`), services refuse to start if:

- `SECRET_KEY` uses the development default (`super-secret-key`)
- `PRIVACY_ADMIN_TOKEN` uses the development default (`dev-privacy-token`)
- `API_TOKEN` is not set (clinical-writer-api)
- Required database or API URLs are missing

This fail-fast behavior is enforced by each service's `Settings.validate_runtime_security()` method.

## Render Config

```bash
python3 tools/scripts/render_runtime_config.py
```

This reads `config/runtime/config.private.json` and writes the generated runtime artifacts under `config/runtime/generated/`.

## Local Docker

1. Copy `config/runtime/config.private.example.json` to `config/runtime/config.private.json`.
2. Fill in the real values.
3. Render the runtime artifacts:

```bash
python3 tools/scripts/render_runtime_config.py
```

4. Start the stack:

```bash
./tools/scripts/compose_local.sh up -d mongodb survey-backend survey-frontend survey-patient clinical-narrative survey-builder survey-worker
```

## VPS Deploy

- `tools/scripts/deploy_vps.sh` now copies `config/runtime/config.private.json` to the server.
- The deploy script renders runtime config on the VPS before `docker compose up -d --build`.

## Public App Config Keys

- `survey-frontend`
  - `apiBaseUrl`
  - `viaCepBaseUrl`
- `survey-patient`
  - `apiBaseUrl`
- `survey-builder`
  - `apiBaseUrl`
- `clinical-narrative`
  - `apiBaseUrl`

## Private Config Coverage

The private JSON currently renders values for:

- MongoDB root credentials and application connection settings
- Survey backend mail/SMTP settings
- Survey backend JWT/security settings
- Survey backend browser security settings, including `CORS_ALLOWED_ORIGINS`
- Survey backend Clinical Writer/LangGraph settings
- Survey worker MongoDB/Clinical Writer/polling settings
- Clinical Writer API auth/runtime settings
- Traefik Let's Encrypt email

## Survey Worker AI Resilience Knobs

The worker includes runtime controls for bounded retries and debug diagnostics.

- `WORKER_MAX_RETRIES`
  - Limits automatic retries for failed AI processing per document.
  - When limit is reached, status transitions to `permanently_failed` and auto polling stops for that document.
- `WORKER_LOG_PAYLOAD`
  - Enables logging of outbound request payload sent to the Clinical Writer.
- `WORKER_LOG_RESPONSE`
  - Enables logging of raw and normalized Clinical Writer responses.

These toggles are intended for incident investigation and should remain disabled in normal production operation unless debugging is needed.

## Production Security Requirements

- `survey-backend`
  - `ENVIRONMENT=production` requires valid HTTPS forwarding and explicit
    `CORS_ALLOWED_ORIGINS`.
  - `SECRET_KEY` must not use the development fallback.
  - `PRIVACY_ADMIN_TOKEN` must not use the development fallback.
- `clinical-writer-api`
  - Set `API_TOKEN` in production for `/process`, `/analysis`, and
    `/transcriptions`.
  - Only use `ALLOW_UNAUTHENTICATED_ACCESS=true` for controlled environments
    where anonymous access is an intentional temporary choice.

## Operational Notes

- Do not rely on permissive browser defaults during deploys. Cross-origin
  access now depends on the configured allowlist, so missing frontend origins
  will fail at the browser boundary.
- Clinical writer request correlation should use pseudonymized `patient_ref`
  values when propagated through runtime config or downstream services.
