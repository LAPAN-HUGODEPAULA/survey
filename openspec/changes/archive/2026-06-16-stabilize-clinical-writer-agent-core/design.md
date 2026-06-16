# Design: stabilize-clinical-writer-agent-core

## Context

This design outlines the stabilization of the Clinical Writer AI multi-agent core. We are standardizing MongoDB as our single source of truth for prompt configuration and removing the obsolete Google Drive prompt provider. To ensure clinical safety, we introduce a formal 4-stage graph containing an automated reflection loop.

## Goals

- Establish MongoDB as the secure source of truth.
- Decommission Google Drive and its associated dependencies.
- Add `ReflectorNode` to validate clinical grounding, tone, and safety.
- Wrap all stage inputs and outputs in typed Pydantic models.
- Decouple data access (MongoDB queries) from routing and registration helper logic.
- Implement an automated startup cleanup routine for audio file retention.

---

## Detailed Architectural Design

### 1. 4-Stage LangGraph with Reflection Loop

The LangGraph orchestration in `agent_graph.py` is expanded to include `ReflectorNode` as the 4th stage, completing the flow:

```
validate_input ➔ route_input ➔ context_loader ➔ clinical_analyzer ➔ persona_writer ➔ reflector
                                                                          ▲            │
                                                                          └─[retry < 2]┘
```

#### Transition logic:
- `persona_writer` always transitions to `reflector`.
- `reflector` parses the generated markdown/JSON report and performs checks (Grounding, Tone, Safety).
- If validation fails and `reflection_retries_used < 2`, it sets `reflection_feedback` and loops back to `persona_writer`.
- If validation passes, or `reflection_retries_used >= 2`, it transitions to `END`.
- If validation is still failing at the retry limit, it adds a warning to the state's `warnings` list before ending the run.

---

### 2. Typed Pydantic Stage Boundaries

Instead of passing untyped dictionaries, each agent node will consume and output validated Pydantic models. This isolates model invocation from dictionary lookup errors.

```python
class ContextLoaderInput(BaseModel):
    input_type: str
    prompt_key: str
    persona_skill_key: Optional[str]
    output_profile: Optional[str]

class ContextLoaderOutput(BaseModel):
    prompt_version: str
    questionnaire_prompt_version: str
    persona_skill_version: str
    prompt_text: str
    interpretation_prompt: str
    persona_prompt: str
    validation_status: str

# Equivalent models (AnalyzerInput/Output, WriterInput/Output, ReflectorInput/Output) 
# will define the boundaries for each subsequent node.
```

---

### 3. Decoupling Data Access (Repositories)

We abstract MongoDB queries into standard repository protocols:

- **`PromptRepository`** (in `repository/prompt_repository.py`):
  - Resolves questionnaire prompt text and metadata.
  - Implements `LocalPromptRepository` (fallback) and `MongoPromptRepository`.
- **`PersonaRepository`** (in `repository/prompt_repository.py`):
  - Resolves persona style sheets and instructions.
  - Implements `MongoPersonaRepository`.
- **`AgentRouteRepository`** (in `repository/agent_route_repository.py`):
  - Decouples `ModelRouter` from MongoDB client creation.
  - Queries `AIAgents` collection for route configs.

Both `ClinicalPromptRegistry` and `ModelRouter` are constructed by injecting these repositories. Direct imports of `pymongo` are restricted to the `repository/` package.

---

### 4. LLM Caching Strategy

To keep API latency and token costs low, the prompts built by the nodes MUST place static context (instructions, persona styles, guidelines) at the **beginning (prefix)** of the LLM prompt. Dynamic data (clinical facts, raw user input) is placed at the **end**. This aligns with Gemini/GLM prefix context caching systems to maximize cache hits.

---

### 5. Safe Audio Retention Startup Hook

Temporary audio files stored under `/tmp/clinical-writer-audio/` during transcription must be removed if a crash or shutdown interrupts standard garbage collection:
- During FastAPI application startup (`lifespan`), a startup task will search the configured audio directory.
- Any files older than 30 minutes are deleted.
- Deletions are written to the configured audio deletions log.
