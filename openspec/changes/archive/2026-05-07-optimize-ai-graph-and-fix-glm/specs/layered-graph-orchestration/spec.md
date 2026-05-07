## MODIFIED Requirements

### Requirement: Clinical Writer MUST use a modular state graph for document generation.
The LangGraph orchestration MUST be composed of distinct phases that operate on a shared, strictly typed `AgentState` defined with `TypedDict`. For the short-term optimized report-generation flow, the graph MUST execute phases in the following default order: Context Loading, Clinical Analysis, and Persona Writing, then terminate. The state contract MUST keep intermediate artifacts such as hydrated prompts, `clinical_facts`, generated report payloads, and model metadata independently inspectable.

#### Scenario: Orchestrating a clinical report generation in optimized mode
- **WHEN** a valid generation request is processed
- **THEN** the request MUST sequentially pass through `ContextLoader`, `ClinicalAnalyzer`, and `PersonaWriter`
- **AND** the graph MUST terminate after `PersonaWriter` in default mode

#### Scenario: Reflection stage is bypassed by default
- **WHEN** the optimized flow is active
- **THEN** the graph MUST NOT invoke `ReflectorNode` for that request path
- **AND** it MUST avoid rewrite loops that depend on reflection iteration counters

#### Scenario: Preserving the graph factory used by FastAPI services
- **WHEN** the orchestration is updated to bypass reflection in default mode
- **THEN** the graph factory surface MUST remain compatible with existing `create_graph(...)` and `clinical_writer_graph` usage
- **AND** callers MUST NOT be required to change how they obtain or invoke the compiled graph

### Requirement: Layered graph nodes MUST use provider-aware routing consistently
The active LLM stages in the optimized layered flow MUST use the same provider-aware routing policy so primary/fallback behavior is consistent across clinical analysis and persona writing.

#### Scenario: Request runs through active graph stages
- **WHEN** a clinical writer request passes through analyzer and writer stages
- **THEN** each active stage MUST resolve LLM invocations through provider-aware primary/fallback routing

### Requirement: Reflection stage MUST use the same provider chain policy
When reflection is explicitly enabled in a future or rollback path, the reflection stage MUST apply the same primary/fallback provider behavior as report generation stages.

#### Scenario: Reflector primary provider fails when reflection is enabled
- **WHEN** reflection is enabled and the reflector primary provider invocation fails
- **THEN** the reflector MUST invoke the fallback provider
- **AND** it MUST continue evaluation using the fallback response when valid
