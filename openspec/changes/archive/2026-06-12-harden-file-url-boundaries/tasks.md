# Tasks

- [x] 1. **Implement Core Helpers**: Create `security_boundaries.py` with `get_safe_write_path` and `validate_outbound_url` logic.
- [x] 2. **Refactor `clinical-writer-api`**:
    - Add `security_boundaries.py` to utilities.
    - Update `metrics_monitor.py` to use `get_safe_write_path`.
    - Update `transcription_retention.py` to use `get_safe_write_path` for audio storage and audit logs.
- [x] 3. **Refactor `survey-backend`**:
    - Add `security_boundaries.py` to utilities.
    - Update `survey_responses.py` and `patient_responses.py` to use `get_safe_write_path` for temporary PDF generation.
    - Update `clinical_writer/client.py` to use `validate_outbound_url` in `_probe_clinical_writer_health`.
- [x] 4. **Refactor `survey-worker`**:
    - Add `security_boundaries.py` to utilities.
    - Update `jobs/clinical_writer.py` to use `validate_outbound_url` before calling `_call_clinical_writer`.
- [x] 5. **Verification**:
    - Add tests for:
        - `../` traversal attempts.
        - symlink-to-sensitive-file write attempts.
        - Metadata IP (`169.254.169.254`) SSRF attempts.
        - Invalid protocol (e.g., `file:///`) attempts.
    - Rerun Skylos and verify findings are addressed.

## Validation

- [x] V1. Unit tests for path helper and URL policy.
- [x] V2. Skylos rerun: path traversal, symlink-following, and SSRF findings should disappear or be explicitly suppressed with justification.
- [x] V3. Manual review of all file writes under services/.
