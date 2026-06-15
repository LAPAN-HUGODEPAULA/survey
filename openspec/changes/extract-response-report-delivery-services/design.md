# Design: extract-response-report-delivery-services

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

- Preserve existing API contracts unless a contract update is intentionally proposed.
- Use repository dependencies from app.persistence.deps as required by project guidance.
- Keep email transport behind an interface so route tests do not send mail.

## Risks / Trade-offs

- Static analysis may report false positives. Implementation must verify source flow, route dependencies, and package roots before deleting or suppressing code.
- Refactors in backend routes and Clinical Writer integration can affect contracts indirectly; validate OpenAPI and generated clients when response/request models change.
- Security hardening may fail previously tolerated invalid configuration; treat this as intentional if documented in the proposal.

## Validation Strategy

- Compile survey-backend.
- Route tests for patient_responses and survey_responses.
- Skylos complexity reductions in create_patient_response/create_survey_response and report formatter helpers.
