# Privacy Governance (LGPD)

## Legal Basis and Documentation

We record the legal basis for each data-processing activity in privacy request metadata
(e.g., consent, legitimate interest, legal obligation). Requests are stored in the
`privacy_requests` collection and can be reviewed by administrators through the privacy
endpoints.

## Data Subject Rights Workflows

### Create a Request
- Endpoint: `POST /api/v1/privacy/requests`
- Purpose: Accepts a data subject request for access, deletion, anonymization, or consent revocation.
- Example payload:
  - `requestType`: `access | deletion | anonymization | consent_revocation`
  - `subjectType`: `patient | screener | clinician | session`
  - `subjectId`: optional identifier
  - `requesterEmail`: optional
  - `details`: optional

### Review or Fulfill Requests
- Endpoints: `GET /api/v1/privacy/requests`, `GET /api/v1/privacy/requests/{id}`
- Update endpoint: `PATCH /api/v1/privacy/requests/{id}`
- Admin access: Requires `X-Privacy-Admin-Token` header matching `PRIVACY_ADMIN_TOKEN`.

### Data Lifecycle Jobs
When a request is fulfilled, the backend creates a lifecycle job in `data_lifecycle_jobs`:
- `deletion` -> `delete`
- `anonymization` -> `anonymize`
- `consent_revocation` -> `revoke_consent`
- `access` -> `export`

## Audit Logging

Privacy request creation and updates emit security audit events stored in the
`security_audit_logs` collection. Each entry includes a hash chain (`prevHash` and
`hash`) to provide tamper-evidence.

Clinical Writer operational logs and run telemetry should avoid direct patient
identifiers when correlation is sufficient. The backend now pseudonymizes
`patient_ref` before storing AI run logs so operators can trace a request
without persisting raw patient email or name in that log stream.

## Encryption Configuration

Transport encryption is enforced via HTTPS in production (`ENVIRONMENT=production`).
At-rest encryption integration points are configured via environment variables:
- `ENCRYPTION_PROVIDER`
- `ENCRYPTION_KEY_ID`

Production runtime also requires:
- explicit `CORS_ALLOWED_ORIGINS` for browser clients
- a non-default `SECRET_KEY`
- a non-default `PRIVACY_ADMIN_TOKEN`
