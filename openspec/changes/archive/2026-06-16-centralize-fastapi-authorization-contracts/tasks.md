# Tasks

- [x] 1. Generate a route inventory mapping method, path, and security model.
- [x] 2. Classify routes into builder, screener, patient link, and public categories.
- [x] 3. Implement central FastAPI dependencies (`require_screener`, `require_template_admin`) in `app/api/dependencies/screener_auth.py`.
- [x] 4. Remove legacy `settings.template_admin_emails` configuration from settings and code, transitioning template administration authorization to the database-level `isBuilderAdmin` check.
- [x] 5. Migrate ad hoc token/header parsing in `screener_routes.py` and `screener_access_links.py` to use `require_screener`.
- [x] 6. Enforce auth dependencies on clinical narrative routes (`chat_sessions.py`, `chat_messages.py`, `clinical_writer.py`, `documents.py`, `voice_transcriptions.py`) and response query routes (`survey_responses.py`).
- [x] 7. Implement the route inventory audit test (`test_route_authorization_audit.py`) using dynamic inspection of `app.routes` to ensure mutating routes require authentication.
- [x] 8. Write robust integration tests for each authentication class using a real test MongoDB instance and signed JWTs (without repository mocks), asserting both rejection (unauthenticated/unauthorized) and success scenarios.
- [x] 9. Verify high code coverage on authentication and route logic.
- [x] 10. Rerun Skylos to verify framework security findings are clean.
- [x] 11. Update developer guidelines (`AGENTS.md`) to document the centralized authorization patterns, dependency-first security structure, and database-first administrative checks.

## Validation

- [x] V1. Run `test_route_authorization_audit.py` to ensure it dynamically validates mutating route security.
- [x] V2. Run integration tests in `test_screener_auth_integration.py` to check authentication/role limits without repository stubs.
- [x] V3. Confirm legacy config removal (check settings coverage for `template_admin_emails`).
- [x] V4. Verify Skylos report is free of authorization triage findings.
- [x] V5. Ensure guidelines in `AGENTS.md` match the implemented centralized security architecture.
