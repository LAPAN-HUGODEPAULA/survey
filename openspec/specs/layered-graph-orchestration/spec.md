# layered-graph-orchestration Specification

## Purpose
TBD - created by archiving change refactor-layered-orchestration. Update Purpose after archive.
## Requirements
### Requirement: Clinical Writer MUST use a modular state graph for document generation.

The LangGraph orchestration MUST be composed of distinct phases that operate on a shared, strictly typed `AgentState` defined with `TypedDict`. For supported report-generation flows, the graph MUST execute the phases in the following order: Context Loading, Clinical Analysis, Persona Writing, and Reflection. The state contract MUST make intermediate artifacts such as hydrated prompts, `clinical_facts`, generated report payloads, reflection feedback, and reflection iteration counters independently inspectable without relying on implicit keys or monolithic writer nodes.

#### Scenario: Orchestrating a clinical report generation
- **Given** a valid generation request mapped to a specific questionnaire and persona
- **WHEN** the state graph executes
- **THEN** the request MUST sequentially pass through the `ContextLoader`, `ClinicalAnalyzer`, `PersonaWriter`, and `ReflectorNode`
- **AND** intermediate states such as hydrated prompts, extracted clinical facts, and reflection outcomes MUST be independently verifiable in the typed agent state

#### Scenario: Reflection requests a controlled rewrite
- **Given** the `ReflectorNode` rejects the generated draft
- **WHEN** the current reflection iteration count is below the configured maximum
- **THEN** the graph MUST route execution back to the `PersonaWriter`
- **AND** it MUST preserve the reflector feedback in state so the writer can revise the report

#### Scenario: Preserving the graph factory used by FastAPI services
- **Given** FastAPI dependencies currently construct or consume the graph through `create_graph(...)` and `clinical_writer_graph`
- **WHEN** the orchestration is refactored to include the reflection stage
- **THEN** the graph factory surface MUST remain compatible with the existing dependency injection flow
- **AND** callers MUST NOT be required to change how they obtain or invoke the compiled graph

#### Scenario: Preserving FastAPI compatibility during graph refactor
- **Given** the FastAPI service invokes the compiled graph from the existing `/process` flow
- **WHEN** the internal graph implementation adds reflection and retry logic
- **THEN** the graph MUST continue to accept the same request-derived state fields and injected dependencies used today
- **AND** the refactor MUST NOT require changes to the external `ProcessRequest` and `ProcessResponse` contract

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
- **Given** a `clinical_facts` object indicating moderate visual distress
- **And** a persona configured for pedagogical (school) tone
- **When** the `PersonaWriter` generates the report
- **Then** the resulting output MUST use accessible language appropriate for educators
- **And** it MUST NOT contradict the severity facts provided by the Analyzer.

