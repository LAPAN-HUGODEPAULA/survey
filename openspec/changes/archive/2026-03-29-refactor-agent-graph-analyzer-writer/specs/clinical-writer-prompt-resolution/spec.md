## MODIFIED Requirements

### Requirement: Clinical Writer MUST resolve questionnaire prompts and persona skills from MongoDB for migrated survey flows.

The prompt resolution mechanism MUST fetch both the `QuestionnairePrompts` document and the `PersonaSkills` document from MongoDB and MUST inject them into the strictly typed `AgentState` as distinct context variables (`interpretation_prompt` and `persona_prompt`) before downstream nodes execute. The `ContextLoader` MUST also persist the resolved version metadata required by the FastAPI service so the analyzer and writer consume only hydrated state, not direct database lookups.

#### Scenario: Route prompts to specialized nodes
- **Given** a survey-derived request that specifies a questionnaire and an output profile
- **WHEN** the `ContextLoader` phase of the graph executes
- **THEN** the state MUST be hydrated with `interpretation_prompt` for the Clinical Analyzer
- **AND** the state MUST be hydrated with `persona_prompt` for the Persona Writer
- **AND** the resolved version fields needed by the service response MUST be written into the agent state before downstream execution

#### Scenario: Preventing downstream database coupling
- **Given** the `ContextLoader` has already resolved questionnaire and persona data from MongoDB
- **WHEN** the `ClinicalAnalyzer` and `PersonaWriter` execute
- **THEN** they MUST consume only the hydrated typed state provided by the graph
- **AND** they MUST NOT perform direct prompt-resolution lookups against the database during normal execution

### Requirement: Clinical Writer MUST preserve a controlled fallback path during migration.

MongoDB-backed prompt composition MUST not break request types that have not yet been migrated to the split prompt model. When the `ContextLoader` cannot resolve the split prompt data, the service MUST either use the documented fallback provider chain or fail with an actionable configuration error that preserves the existing FastAPI error semantics for callers.

#### Scenario: A non-migrated prompt flow is requested
- **Given** a request reaches `clinical-writer-api` for a flow that does not yet have both MongoDB prompt components
- **WHEN** prompt resolution runs
- **THEN** the service MUST use the documented fallback provider chain or fail with an actionable configuration error
- **AND** non-migrated flows such as `clinical-narrative` MUST remain operational during the migration window

#### Scenario: Prompt resolution fails for an existing FastAPI caller
- **Given** the `/process` endpoint invokes the graph with existing dependencies
- **WHEN** the `ContextLoader` cannot resolve the required prompt data
- **THEN** the graph MUST surface an actionable error through the existing service error path
- **AND** the caller MUST not be required to change the request payload or integration contract to receive that failure
