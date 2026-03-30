## 1. State Contract And Graph Topology

- [x] 1.1 Tighten `AgentState` in `agents/agent_state.py` so request inputs, hydrated prompts, intermediate facts, final outputs, and error metadata are explicitly represented in the `TypedDict`.
- [x] 1.2 Refactor `agent_graph.py` so supported generation flows always execute `ContextLoader` → `ClinicalAnalyzer` → `PersonaWriter` without monolithic writer shortcuts.
- [x] 1.3 Ensure graph transitions and node outputs rely on explicit typed state keys rather than implicit combined prompt fields.
- [x] 1.4 Preserve the current `create_graph(...)` integration surface and compiled graph wiring expected by `main.py` and existing FastAPI dependencies.

## 2. Layered Node Responsibilities

- [x] 2.1 Update `ContextLoaderAgent` to hydrate `interpretation_prompt`, `persona_prompt`, and prompt version metadata from the injected registry before downstream execution.
- [x] 2.2 Update `ClinicalAnalyzerAgent` so it consumes only source input plus interpretation context and emits structured `clinical_facts` without end-user narrative prose.
- [x] 2.3 Update `PersonaWriterAgent` so it consumes `clinical_facts` plus persona instructions as its clinical source of truth and preserves the current report output shape.
- [x] 2.4 Preserve documented fallback or actionable failure behavior when split prompt data is unavailable for a request.

## 3. FastAPI Compatibility And Validation

- [x] 3.1 Verify `main.py` continues to invoke the graph with the existing dependency-injected `graph`, `observer`, and `prompt_registry` flow and does not require `ProcessRequest` or `ProcessResponse` changes.
- [x] 3.2 Update or add unit tests covering typed state handoff, context hydration, analyzer-to-writer chaining, and `/process` error semantics.
- [x] 3.3 Run the relevant clinical writer test suite and confirm the refactor preserves current FastAPI behavior.
- [x] 3.4 Run `openspec validate refactor-agent-graph-analyzer-writer --strict`.
