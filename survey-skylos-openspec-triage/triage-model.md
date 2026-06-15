# Skylos Python Report v1 Triage Model

Source inputs:

- `AGENTS.md` project guidance.
- `Skylos-python-report-v1.txt` from `skylos . -a` run inside `services/`.

## Executive Summary

Skylos analyzed 193 Python files and assigned grade F (26/100). The raw report has 285 security rows, 579 quality rows, 8 dead-code items, 16 secret rows, and 42 dependency-vulnerability rows.

The report should not be read line by line. Treat it as a signal source and group findings by durable refactor leverage:

1. Security boundaries and configuration hygiene.
2. Packaging/dependency correctness so future reports are not dominated by false positives.
3. Cross-cutting route authorization contracts.
4. High-complexity integration and report-delivery seams.
5. Baseline-aware quality gates.
6. Low-leverage cleanup after the systemic proposals are started.

## Noise and Exclusion Policy

Ignore or suppress these for the first Python-backend triage pass:

- `.skylos/cache/**`: generated analyzer cache, not application code.
- `package-lock.json`: outside the requested Python backend focus; high-entropy rows are probably lockfile integrity/hash noise.
- Generated SDKs, build outputs, virtualenvs, caches, and package manager artifacts.
- `examples_observer_pattern.py`: example/support code unless it is imported by production.
- `services/**/tests/**`: do not let test-only issues outrank production seams. Use them for regression coverage, not as primary refactor drivers.
- `app` and `clinical_writer_agent` dependency findings: likely first-party import-root false positives caused by scan context. Do not add fake PyPI dependencies.

## Confidence Model

Use four confidence tiers:

| Tier | Meaning | Examples in this report | Action |
|---|---|---|---|
| Confirmed | Location and semantics strongly imply a real issue. | `.env` secret rows; 100% unused imports. | Fix directly or open a narrow proposal. |
| Probable | Production location and known dangerous pattern, but exploitability depends on source flow. | Path traversal, symlink writes, SSRF. | Create hardening proposal and verify flows during implementation. |
| Needs verification | Analyzer may miss app-level context. | Framework Security route auth rows; dependency manifests; SCA reachability. | Inventory and design a systemic fix before changing many lines. |
| Noise | Generated, lockfile, first-party package, or support-only context. | `.skylos/cache`, `package-lock.json`, local package hallucinations. | Suppress or exclude from triage. |

## Refactor Leverage Scoring

Rank findings by this decision rule:

`leverage = production risk + repeated pattern + architectural seam + future-noise reduction - implementation blast radius`

Severity is only one input. For example, dependency hallucination rows marked Critical are lower leverage than the Clinical Writer integration client refactor because they are probably first-party import-root noise. Conversely, the SSRF/path traversal cluster is high leverage because it defines a reusable runtime boundary.

## Prioritized OpenSpec Change Backlog

| Rank | Change ID | Leverage | Confidence | Primary scope |
|---:|---|---|---|---|
| 1 | `harden-runtime-secrets-config` | Very high | High | security-config |
| 2 | `harden-file-url-boundaries` | Very high | High for locations, medium for exploitability until source flow is inspected | runtime-boundaries |
| 3 | `formalize-python-service-packaging` | Very high | High that analyzer context is noisy; medium on exact dependency manifests until pyproject files are inspected | python-platform |
| 4 | `centralize-fastapi-authorization-contracts` | High | Medium: findings may be false positives if router-level or middleware guards exist | backend-auth |
| 5 | `decompose-clinical-writer-integration-client` | High | High for complexity and size findings | clinical-writer-integration |
| 6 | `extract-response-report-delivery-services` | High | High for complexity/duplication, medium for auth until route inventory is done | report-delivery |
| 7 | `stabilize-clinical-writer-agent-core` | Medium-high | High for quality/architecture findings, medium on exact refactor boundaries until source is inspected | clinical-writer-agent |
| 8 | `introduce-python-quality-gates` | Medium-high | High | code-quality |

## Raw Finding Categories After Triage

| Category | Raw count | Triage treatment |
|---|---:|---|
| Real secrets in clinical-writer `.env` | 4 | Confirmed. Immediate remediation proposal. |
| Generated/irrelevant secret noise | 12 | Suppress: `.skylos/cache/**` and `package-lock.json`. |
| Path traversal / symlink / SSRF boundary rows | 10 | Probable. One shared runtime-boundary proposal. |
| Undeclared dependency rows | 263 | Mostly packaging/analyzer context. One service-packaging proposal. |
| Dependency hallucination rows | 12 | Local package false-positive class. Fold into packaging proposal. |
| Framework Security route rows | 36 | Needs route inventory; central auth proposal. |
| Typing rows | 131 | Quality-gate proposal; do not fix one-by-one initially. |
| Complexity rows | 43 | Refactor high-centrality functions first: Clinical Writer client, response/report delivery, agent core. |
| Structure rows | 49 | Same as complexity; line count alone is not enough. |
| Architecture rows | 26 | Clinical Writer agent core proposal. |
| Clone rows | 18 | Fold into report delivery / shared formatter work. |
| Unused imports | 5 | Quick cleanup; no OpenSpec proposal needed unless bundled with quality gates. |
| Unused classes | 3 | Verify dynamic registration before deletion; parking lot. |
| SCA dependency vulnerability rows | 42 | Inconclusive. Confirm with dependency audit after manifests are fixed. |

## Parking Lot: Do Not Start Here

These are valid cleanup items but lower leverage than the proposals above:

- Remove 5 unused imports after compile checks.
- Verify whether `ConsultWriterNode`, `Survey7WriterNode`, and `FullIntakeWriterNode` are dynamically referenced before deletion.
- Move or exclude example/debug code if `examples_observer_pattern.py` is not production.
- Normalize repeated string constants only when touching the owning module for a larger refactor.
- Address dependency vulnerability rows only after service manifests are correct and a current audit confirms reachability/fix versions.

## Suggested Execution Order

1. Start with `harden-runtime-secrets-config` because credential exposure has immediate operational risk and minimal code coupling.
2. Do `harden-file-url-boundaries` before report-delivery and integration-client refactors so the safe helpers exist.
3. Do `formalize-python-service-packaging` early to reduce false positives and make all subsequent Skylos deltas meaningful.
4. Then choose between `centralize-fastapi-authorization-contracts` and the high-complexity refactors depending on release pressure.
5. Add quality gates after the packaging model is stable, otherwise the gates will encode the current analyzer noise.
