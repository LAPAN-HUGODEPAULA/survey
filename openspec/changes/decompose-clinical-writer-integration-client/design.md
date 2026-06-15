# Design: decompose-clinical-writer-integration-client

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

- Keep the transport client thin and deterministic; keep fallback policy separate from HTTP plumbing.
- Use dependency injection for the httpx client to simplify tests.
- Coordinate with harden-file-url-boundaries so endpoint validation is reused rather than reimplemented.

## Risks / Trade-offs

- Static analysis may report false positives. Implementation must verify source flow, route dependencies, and package roots before deleting or suppressing code.
- Refactors in backend routes and Clinical Writer integration can affect contracts indirectly; validate OpenAPI and generated clients when response/request models change.
- Security hardening may fail previously tolerated invalid configuration; treat this as intentional if documented in the proposal.

## Validation Strategy

- Existing clinical writer client tests pass.
- New unit tests for each extracted component.
- Skylos complexity for send_to_langgraph_agent is eliminated because the function no longer exists or is a small orchestrator.
