# clinical-writer-prompt-resolution Specification

## Purpose
TBD - created by archiving change add-survey-ai-prompts. Update Purpose after archive.
## Requirements
### Requirement: Clinical Writer MUST resolve questionnaire prompts and persona skills from MongoDB for migrated survey flows.

The prompt resolution mechanism MUST fetch both the `QuestionnairePrompts` document and the `PersonaSkills` document from MongoDB and MUST inject them into the strictly typed `AgentState` as distinct context variables (`interpretation_prompt` and `persona_prompt`) before downstream nodes execute. The `ContextLoader` MUST also persist the resolved version metadata required by the FastAPI service so the analyzer and writer consume only hydrated state, not direct database lookups.

#### Scenario: Route prompts to specialized nodes
- **Given** a survey-derived request that specifies a questionnaire and an output profile
- **When** the `ContextLoader` phase of the graph executes
- **Then** the state MUST be hydrated with `interpretation_prompt` for the Clinical Analyzer
- **And** the state MUST be hydrated with `persona_prompt` for the Persona Writer
- **And** the resolved version fields needed by the service response MUST be written into the agent state before downstream execution

#### Scenario: Preventing downstream database coupling
- **Given** the `ContextLoader` has already resolved questionnaire and persona data from MongoDB
- **When** the `ClinicalAnalyzer` and `PersonaWriter` execute
- **Then** they MUST consume only the hydrated typed state provided by the graph
- **And** they MUST NOT perform direct prompt-resolution lookups against the database during normal execution

### Requirement: Clinical Writer MUST preserve a controlled fallback path during migration.

MongoDB-backed prompt composition MUST not break request types that have not yet been migrated to the split prompt model. When the `ContextLoader` cannot resolve the split prompt data, the service MUST either use the documented fallback provider chain or fail with an actionable configuration error that preserves the existing FastAPI error semantics for callers.

#### Scenario: A non-migrated prompt flow is requested
- **Given** a request reaches `clinical-writer-api` for a flow that does not yet have both MongoDB prompt components
- **When** prompt resolution runs
- **Then** the service MUST use the documented fallback provider chain or fail with an actionable configuration error
- **And** non-migrated flows such as `clinical-narrative` MUST remain operational during the migration window

#### Scenario: Prompt resolution fails for an existing FastAPI caller
- **Given** the `/process` endpoint invokes the graph with existing dependencies
- **When** the `ContextLoader` cannot resolve the required prompt data
- **Then** the graph MUST surface an actionable error through the existing service error path
- **And** the caller MUST not be required to change the request payload or integration contract to receive that failure

### Requirement: Clinical Writer MUST apply MongoDB prompt edits on the next request without requiring a deploy.

Updates to migrated `QuestionnairePrompts` and `PersonaSkills` documents MUST become effective for subsequent requests without rebuilding containers, redeploying services, or restarting the Clinical Writer process.

#### Scenario: Physician edits the school report persona
- **Given** a physician updates the `PersonaSkills` document used for the school report output profile
- **When** the next school report request is processed
- **Then** the Clinical Writer MUST use the updated persona instructions
- **And** the request MUST complete without requiring a new deploy or a process restart
