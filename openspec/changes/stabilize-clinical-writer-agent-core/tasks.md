# Tasks: stabilize-clinical-writer-agent-core

- [x] **1. Decommission Google Drive Provider**
  - Delete `GoogleDrivePromptProvider` in `prompt_registry.py`.
  - Remove `google-api-python-client` and `google-auth` from dependency requirements in `pyproject.toml`.
  - Sync lock files (`uv lock` / `uv sync`).
  - Delete deprecated Google Drive env variables in `settings.py` and `config/runtime/config.private.example.json`.

- [x] **2. Extract and Implement Repository Layer**
  - Define repository protocols (`PromptRepository`, `PersonaRepository`, `AgentRouteRepository`).
  - Create `clinical_writer_agent/repository/prompt_repository.py` and implement Mongo / Local providers.
  - Create `clinical_writer_agent/repository/agent_route_repository.py` and implement Mongo agent route queries.
  - Decouple `prompt_registry.py` and `layered_node_utils.py` from direct `pymongo` imports.

- [x] **3. Implement Pydantic State Boundaries**
  - Create `clinical_writer_agent/agents/schemas.py`.
  - Define input and output Pydantic schemas for `ContextLoader`, `ClinicalAnalyzer`, `PersonaWriter`, and `Reflector`.
  - Update agent classes to parse state dictionary items into Pydantic models before executing agent logic, and dump results back.

- [x] **4. Build and Wire ReflectorNode**
  - Create `clinical_writer_agent/agents/reflector_agent.py`.
  - Implement LLM-based checks for Grounding, Tone, and Safety.
  - Add reflection-related properties (`reflection_feedback`, `reflection_retries_used`) to `AgentState`.
  - Update `agent_graph.py` to register the `reflector` node and define conditional routing loops from `persona_writer` back to it.

- [x] **5. Normalize Observers**
  - Update `ProcessingMonitor` in `base_monitors.py` to provide default empty `pass` implementations for all hooks.
  - Simplify subclasses (`ProgressMonitor`, `LoggingMonitor`) by deleting unused empty hook definitions.

- [x] **6. Add Startup Audio Cleanup Hook**
  - Write residual cleanup helper in `transcription_retention.py` utilizing safe path utilities from `lapan_core`.
  - Hook the cleanup helper into `main.py` lifespan application startup.

- [x] **7. Implement Tests & Verification**
  - Add unit tests for `ReflectorNode` and reflection loop routing.
  - Verify prefix prompt layout remains compliant with LLM provider caching rules.
  - Run the full test suite with coverage (`pytest --cov`) and verify compile checks (`python -m compileall`).
