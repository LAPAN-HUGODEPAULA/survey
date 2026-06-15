# Change: harden-file-url-boundaries

## Why

Filesystem and outbound HTTP boundaries are cross-cutting security seams. Fixing them once through consistent helpers reduces repeated path/URL audit burden and ensures uniform protection across all Python services.

## What Changes

- Introduce a standardized `security_boundaries.py` utility in every Python service to handle safe path resolution and URL validation.
- **Filesystem Hardening**: Implement base-directory containment checks and explicit symlink rejection (using `O_NOFOLLOW` or `is_symlink()`) for metrics, transcription retention, audit logs, and generated report attachments.
- **Network Hardening**: Constrain all outbound URLs to the Clinical Writer API to configured service origins, supported schemes (http/https), and authorized hosts, while blocking private-network metadata IPs (SSRF protection).
- **Service Parity**: Apply the same outbound URL policy to both `survey-backend` and `survey-worker`.
- **Validation**: Add unit tests for traversal payloads, symlink targets, private IP/metadata SSRF targets, and allowed internal service URLs.

## Scope

`survey-backend`, `survey-worker`, and `clinical-writer-api`. Focuses on file writes and outbound HTTP integration points.

## Impact

- Affected capability: `runtime-boundaries`
- Refactor leverage: Very high
- Confidence: High
- Expected implementation style: "Consistent duplication" of security primitives across services to minimize cross-project dependency complexity.

## Evidence From Skylos v1

- Path traversal and symlink-following write findings occur in `clinical-writer-api/monitoring/metrics_monitor.py:140` and `transcription_retention.py:19, :23, :39`.
- Path traversal is reported in `survey-backend/app/api/routes/patient_responses.py:248` and `survey_responses.py:275`.
- A critical SSRF finding is reported at `survey-backend/app/integrations/clinical_writer/client.py:113` in `_probe_clinical_writer_health`.
- `survey-worker` performs identical unconstrained outbound calls in `_call_clinical_writer`.
