## MODIFIED Requirements

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
