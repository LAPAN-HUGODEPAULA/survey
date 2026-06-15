# Design: harden-file-url-boundaries

## Context

This change was produced from Skylos Python report v1 triage. The intent is to convert static-analysis clusters into a bounded, reviewable implementation plan rather than fixing isolated lines without architecture context.

## Goals

- Eliminate high-confidence Skylos findings related to Path Traversal, SSRF, and Symlink-following.
- Provide a standardized pattern for safe file and network operations across Python services.
- Ensure `survey-worker` and `survey-backend` share the same security posture for outbound calls.

## Decisions

- **Standardized Utility**: Create a `security_boundaries.py` file in the core utility folder of every Python service. This file will contain identical, vetted logic for path and URL validation.
- **Path Validation Pattern**:
    - Resolve candidate paths using `os.path.realpath` to handle `../` and symlinks.
    - Assert that the resolved path is strictly contained within the intended base directory.
    - Explicitly check `is_symlink()` before any write operation to prevent hijacking of pre-existing symlinks.
- **URL Validation Pattern**:
    - Create a `validate_outbound_url(url, allowed_hosts)` helper.
    - Block link-local addresses (e.g., `169.254.169.254`) and loopback (`127.0.0.1`, `localhost`) in production environments.
    - Enforce restricted schemes (`http`, `https`).
- **Untrusted Configuration**: Treat URLs from environment variables as untrusted inputs that must pass through the validation policy before being used in an HTTP client.

## Risks / Trade-offs

- **Consistent Duplication**: Maintaining identical logic in three places requires discipline. This is a trade-off to avoid the complexity of an internal cross-service package repository.
- **Strictness**: Hardening may break existing development workflows if local hostnames are not correctly allowed in the policy.
