## Context

The Clinical Writer flow is failing in production with the user-facing timeout/error message "A análise está demorando mais que o esperado. Tente novamente em instantes." The failure is caused by a runtime mismatch in the GLM provider client: `GLMClient.invoke()` is synchronous but internally executes `asyncio.run(...)`, which crashes when called from a running event loop in FastAPI request handling.

Because GLM fails immediately, provider routing always falls back to Gemini. The current layered graph executes three LLM-heavy stages (Analyzer -> PersonaWriter -> Reflector), so fallback traffic rapidly exhausts Gemini free-tier quota and returns 429 errors.

This change targets immediate service stabilization and cost reduction while preserving the existing API contract.

## Goals / Non-Goals

**Goals:**
- Remove the GLM runtime event-loop conflict so GLM can be used as the primary provider again.
- Reduce per-request LLM usage by bypassing reflection in the short term (3 calls -> 2 calls baseline).
- Preserve the Analyzer -> PersonaWriter separation for clinical interpretation quality.
- Keep `/process` request/response behavior and contract unchanged.

**Non-Goals:**
- Replacing the layered architecture with a single-call writer in this change.
- Removing `ReflectorNode` implementation from the codebase.
- Redesigning questionnaire prompts, persona content, or response schema.

## Decisions

1. Use synchronous GLM client invocation with OpenAI-compatible SDK
- Decision: Refactor `GLMClient` to use synchronous `openai.OpenAI` client invocation end-to-end inside `invoke()`.
- Rationale: The graph invocation path is currently synchronous in service code; using synchronous provider calls removes nested event-loop hazards.
- Alternative considered: Keep `AsyncOpenAI` and make graph/service fully async. Rejected for this change because it is broader, riskier, and slower to stabilize.

2. Bypass reflection in active graph path
- Decision: Route the default generation flow from `PersonaWriter` directly to `END`, bypassing `ReflectorNode` and reflection rewrite loops.
- Rationale: Reflection is the highest avoidable token/cost multiplier in the current architecture and not required to produce a valid report payload.
- Alternative considered: One-shot FastPath writer. Rejected short-term due to higher quality/regression risk without prompt redesign.

3. Keep reflection code available for future reactivation
- Decision: Keep `ReflectorNode` implementation and provider routing logic in code, but remove it from the default execution path.
- Rationale: Enables quick rollback or controlled re-enable after quota and quality validation.
- Alternative considered: Delete reflection stage entirely. Rejected to avoid irreversible churn during incident mitigation.

4. Maintain existing provider fallback policy
- Decision: Preserve GLM primary -> Gemini fallback behavior in model routing.
- Rationale: Fallback remains necessary for resilience when GLM errors occur.
- Alternative considered: Disable fallback to protect Gemini quota. Rejected because it would reduce availability during GLM outage.

## Risks / Trade-offs

- [Reduced automated quality control] -> Mitigation: keep Analyzer/Persona split, add explicit monitoring for output regressions, and retain reflector code for re-enable.
- [GLM SDK behavior differences after sync refactor] -> Mitigation: add focused tests for successful invocation and fallback paths, validate error mapping.
- [Higher dependence on prompt quality without reflection rewrite] -> Mitigation: ensure PersonaWriter prompt includes stricter output constraints and track post-deploy report quality.
- [Fallback can still exhaust quota under sustained primary failure] -> Mitigation: improve provider failure telemetry and alerting to detect persistent GLM outage early.

## Migration Plan

1. Implement and test synchronous GLM client refactor.
2. Update graph edges to bypass reflection in default route.
3. Run compile/lint/tests for `services/clinical-writer-api`.
4. Deploy incrementally and monitor: GLM success rate, fallback rate, latency, and 429 frequency.
5. Rollback plan:
- If GLM sync refactor fails, revert provider client changes.
- If output quality degrades, re-enable reflection path from existing node implementation (or rollback graph edge changes).

## Open Questions

- Should reflection bypass be controlled by an environment flag in this change or hardcoded as default behavior?
- What quantitative quality threshold will trigger reflection reactivation?
- Do we need temporary rate limiting/circuit breaker on Gemini fallback while GLM health is unstable?
