# layered-graph-orchestration Specification

## Purpose
Establishes the architectural requirement to transition the Clinical Writer from monolithic prompt nodes to a 4-stage sequential state graph to enhance reasoning, modularity, and safety in report generation.

## ADDED Requirements

### Requirement: Clinical Writer MUST use a modular state graph for document generation.

The LangGraph orchestration MUST be composed of distinct phases that operate on a shared, strictly typed `AgentState`. The minimal phases MUST include: Context Loading, Clinical Analysis, and Persona Writing.

#### Scenario: Orchestrating a clinical report generation
- **Given** a valid generation request mapped to a specific questionnaire and persona
- **When** the state graph executes
- **Then** the request MUST sequentially pass through the ContextLoader, ClinicalAnalyzer, and PersonaWriter
- **And** intermediate states such as extracted clinical facts MUST be independently verifiable in the agent state.

### Requirement: Clinical Analyzer MUST produce structured facts without narrative prose.

The analysis node MUST process input data strictly using clinical logic and MUST output a structured JSON object (`clinical_facts`). It MUST NOT generate natural language narrative intended for the end-user.

#### Scenario: Analyzing visual hypersensitivity responses
- **Given** an input JSON containing severe photophobia responses
- **When** the `ClinicalAnalyzer` processes the data
- **Then** the output MUST be a JSON object like `{"photophobia_severity": "severe"}`
- **And** the output MUST NOT contain full sentences such as "The patient presents with severe photophobia."

### Requirement: Persona Writer MUST consume structured facts to generate styled Markdown.

The writing node MUST rely on the `clinical_facts` produced by the Analyzer and the stylistic rules defined by the Persona. It MUST output the final report in Markdown format.

#### Scenario: Writing a school report from facts
- **Given** a `clinical_facts` object indicating moderate visual distress
- **And** a persona configured for pedagogical (school) tone
- **When** the `PersonaWriter` generates the report
- **Then** the resulting Markdown MUST use accessible language appropriate for educators
- **And** it MUST NOT contradict the severity facts provided by the Analyzer.