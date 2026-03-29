## 1. Graph And State Wiring

- [x] 1.1 Extend `AgentState` to include reflection status, corrective feedback, iteration counters, and any error metadata needed for reflection failure handling.
- [x] 1.2 Refactor `agent_graph.py` so supported report flows execute `ContextLoader` → `ClinicalAnalyzer` → `PersonaWriter` → `ReflectorNode`.
- [x] 1.3 Add conditional edges so reflection PASS ends the workflow, reflection FAIL routes back to `PersonaWriter`, and exceeded iteration limits terminate with actionable failure.
- [x] 1.4 Preserve the current `create_graph(...)`, `clinical_writer_graph`, and FastAPI dependency injection surfaces while introducing a dedicated critique-model injection path.

## 2. ReflectorNode And Safety Policy

- [x] 2.1 Implement `ReflectorNode` to evaluate generated drafts using a superior critique model and emit structured PASS/FAIL decisions with corrective feedback.
- [x] 2.2 Enforce mandatory reflection criteria for audience tone and absence of invasive medical recommendations in non-medical profiles such as school-facing reports.
- [x] 2.3 Update `PersonaWriter` so it can consume reflector feedback during rewrite attempts without changing `clinical_facts` as the clinical source of truth.
- [x] 2.4 Configure and document the maximum of 2 corrective reflection iterations before surfacing a non-convergence failure.

## 3. Compatibility, Tests, And Validation

- [x] 3.1 Verify `main.py` continues to return the existing `ProcessResponse` contract while internal reflection retries remain transparent to callers.
- [x] 3.2 Add unit and contract tests covering reflection PASS, school-report rejection for invasive recommendation, tone rejection, rewrite loop handoff, and failure after the iteration cap.
- [x] 3.3 Run the relevant clinical writer test suite to confirm the reflection stage preserves current FastAPI behavior for successful requests and actionable failures.
- [x] 3.4 Run `openspec validate add-reflector-node-clinical-safety --strict`.
