# layered-graph-orchestration Specification

## Purpose
TBD - created by archiving change refactor-layered-orchestration. Update Purpose after archive.
## Requirements
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

### Requirement: Clinical Analyzer MUST produce structured facts without narrative prose.

The analysis node MUST process input data strictly using clinical logic and MUST output a structured JSON object (`clinical_facts`). It MUST consume the source content together with the hydrated `interpretation_prompt` and MUST NOT generate natural language narrative intended for the end-user or persona-specific formatting.

#### Scenario: Analyzing visual hypersensitivity responses
- **Given** an input JSON containing severe photophobia responses
- **And** the state already contains the `interpretation_prompt` resolved for that questionnaire
- **When** the `ClinicalAnalyzer` processes the data
- **Then** the output MUST be a JSON object like `{"photophobia_severity": "severe"}`
- **And** the output MUST NOT contain full sentences such as "The patient presents with severe photophobia."

### Requirement: Persona Writer MUST consume structured facts to generate styled Markdown.

The writing node MUST rely on the `clinical_facts` produced by the Analyzer together with the hydrated persona instructions. It MUST generate the final report output from those structured facts and MUST NOT depend on monolithic prompt text or direct clinical reinterpretation of the raw request content as its primary source of truth.

#### Scenario: Writing a school report from facts
-   **Given** a `clinical_facts` object indicating moderate visual distress
-   **And** a persona configured for pedagogical (school) tone
-   **When** the `PersonaWriter` generates the report
-   **Then** the resulting output MUST use accessible language appropriate for educators
-   **And** it MUST NOT contradict the severity facts provided by the Analyzer.

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


