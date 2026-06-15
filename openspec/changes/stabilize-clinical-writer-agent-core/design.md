# Design: stabilize-clinical-writer-agent-core

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

- Prefer narrow protocols over inheritance-heavy agent classes where possible.
- Keep clinical interpretation separate from narrative formatting as required by project guidance.
- Do not change prompt semantics unless tests demonstrate the refactor preserves output constraints.

## Risks / Trade-offs

- Static analysis may report false positives. Implementation must verify source flow, route dependencies, and package roots before deleting or suppressing code.
- Refactors in backend routes and Clinical Writer integration can affect contracts indirectly; validate OpenAPI and generated clients when response/request models change.
- Security hardening may fail previously tolerated invalid configuration; treat this as intentional if documented in the proposal.

## Validation Strategy

- Clinical Writer API contract tests.
- Graph default-flow tests.
- Skylos rerun with reduced architecture/complexity hotspots.
