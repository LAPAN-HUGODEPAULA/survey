# Design: centralize-fastapi-authorization-contracts

## Context

This change was produced from Skylos Python report v1 triage. The intent is to convert static-analysis clusters into a bounded, reviewable implementation plan rather than fixing isolated lines without architecture context.

## Goals

- Reduce high-confidence or high-leverage Skylos findings in the stated scope.
- Preserve behavior unless a requirement explicitly changes it.
- Add tests that make the intended boundary or refactor observable.
- Keep changes small enough for review and rollback.

## Non-Goals

- Broad formatting-only rewrites.
- Blind dependency upgrades or suppressions.
- Generated-file cleanup unrelated to this capability.

## Decisions

- **FastAPI Dependency Injection**: Use FastAPI `Depends(...)` for all authentication and authorization checks, completely eliminating ad hoc token/header parsing in route bodies.
- **Unified Screener Dependency (`app/api/dependencies/screener_auth.py`)**:
  * Implement `require_screener(authorization: Optional[str] = Header(None, alias="Authorization"), repo: ScreenerRepository = Depends(get_screener_repo)) -> ScreenerModel` to validate bearer tokens and resolve active screeners.
  * Implement `require_template_admin(screener: ScreenerModel = Depends(require_screener)) -> ScreenerModel` to validate template administration access using the database-level `isBuilderAdmin` flag, deprecating and removing the legacy `settings.template_admin_emails` configuration.
- **Builder Authentication (`app/api/dependencies/builder_auth.py`)**: Continue using cookie-based session tokens (`require_builder_admin`) and CSRF validation (`require_builder_csrf`) for `survey-builder` administrative routes.
- **Route Authorization Audit Strategy**: Implement a test-level audit that inspects `app.routes` and validates that all mutating endpoints are protected or marked explicitly as a public exception.
- **Layer Boundary Preservation**: Keep repositories and service layers focused purely on business logic/data persistence, shifting authorization checks to the FastAPI routing layer.

## Risks / Trade-offs

- Static analysis may report false positives. Implementation must verify source flow, route dependencies, and package roots before deleting or suppressing code.
- Refactors in backend routes and Clinical Writer integration can affect contracts indirectly; validate OpenAPI and generated clients when response/request models change.
- Security hardening may fail previously tolerated invalid configuration; treat this as intentional if documented in the proposal.
- **Testing Integrity & Mocking Strategy**: To avoid weak or brittle tests, do NOT mock repository interfaces or stub out route dependencies. Tests must verify the security boundary using actual MongoDB calls (using the test database) and real JWT token signatures. Mocks should only be used for external systems (e.g., SMTP email delivery and LangGraph API endpoints).

## Validation Strategy

- **Route Inventory Audit Test**: Programmatic test in `test_route_authorization_audit.py` that iterates over `app.routes` and asserts that all mutating endpoints are protected.
- **High-Coverage Request Validation Tests**: Direct HTTP tests verifying that:
  * Protected endpoints reject requests with missing, malformed, or expired tokens.
  * Protected endpoints reject requests with valid tokens if the user lacks the required role (`isBuilderAdmin`).
  * Endpoints succeed and behave correctly when provided with a valid token corresponding to a user with matching permissions in the database.
- **Skylos Verification**: Rerun the scanner to confirm security alerts are resolved.
