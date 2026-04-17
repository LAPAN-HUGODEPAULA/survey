# clinical-writer-prompt-resolution Specification

## Purpose
TBD - created by archiving change add-survey-ai-prompts. Update Purpose after archive.
## Requirements
### Requirement: Clinical Writer MUST resolve questionnaire prompts and persona skills from MongoDB for migrated survey flows and **MUST expose internal processing stages**.

The prompt resolution mechanism MUST fetch both the `QuestionnairePrompts` document and the `PersonaSkills` document from MongoDB and MUST inject them into the strictly typed `AgentState`. The `clinical-writer-api` SHALL expose its progress through standardized job stages (e.g., `loading_context`, `analyzing`, `writing`, `reflecting`) to allow callers to provide granular progress feedback to users.

#### Scenario: Route prompts to specialized nodes and report stage
- **Given** a survey-derived request that specifies a questionnaire and an output profile
- **When** the `ContextLoader` phase of the graph executes
- **Then** the state MUST be hydrated with `interpretation_prompt` and `persona_prompt`
- **AND** the API SHALL report the current stage as `loading_context`.

#### Scenario: Report transition to drafting stage
- **Given** the Clinical Analyzer has finished producing structured facts
- **WHEN** the `PersonaWriter` node begins execution
- **THEN** the job status SHALL update the `currentStage` to `writing`
- **AND** the `stageMessage` MUST update to a pt-BR string explaining that the narrative is being written.

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

### Requirement: Prompt-resolution documentation MUST match the questionnaire-plus-persona runtime model
The documented Clinical Writer architecture MUST describe runtime prompt composition as the combination of questionnaire prompts, persona skills, output profiles, and access-point bindings rather than as one undifferentiated prompt document.

#### Scenario: Engineer consults prompt-resolution documentation
- **WHEN** a developer or operator reads the Clinical Writer prompt-resolution reference
- **THEN** the documentation MUST describe how questionnaire prompts and persona skills are combined for runtime execution
- **AND** it MUST explain how access-point configuration selects the final stack for a given flow

### Requirement: The platform MUST provide a research brief before publishing the bootstrap catalog
Before the initial catalog is published to Mongo for runtime use, the platform MUST provide a structured research brief that supports deeper prompt-quality review and refinement.

#### Scenario: Team prepares a prompt-quality review cycle
- **WHEN** the team is ready to refine the starter catalog with deeper prompt research
- **THEN** the documentation set MUST include a research brief summarizing the current architecture, open quality questions, and evaluation criteria
- **AND** the brief MUST be detailed enough to support an external or internal Deep Research workflow

### Requirement: Survey-driven Clinical Writer requests MUST resolve through builder-managed access points
For survey-driven report generation, the Clinical Writer runtime MUST resolve its effective `promptKey`, `personaSkillKey`, and `outputProfile` from builder-managed access-point configuration before consulting survey defaults or legacy fallbacks.

#### Scenario: Patient flow invokes a configured access point
- **WHEN** a survey-driven request reaches the backend with an `accessPointKey` that exists in the builder-managed configuration
- **THEN** the runtime MUST load the prompt stack defined for that access point
- **AND** it MUST use those resolved values when hydrating the Clinical Writer state

#### Scenario: Access point is missing for a migrated flow
- **WHEN** a migrated survey-driven flow invokes the runtime without a valid configured access point
- **THEN** the system MUST fail with an actionable configuration error or documented fallback behavior
- **AND** it MUST not silently substitute an unrelated prompt stack

### Requirement: Survey-driven runtime MUST use Mongo-managed catalogs as the primary source
Survey-driven Clinical Writer resolution MUST use Mongo-managed administrative catalogs as the primary prompt source for migrated flows, leaving Google Drive only as an explicit fallback for non-migrated or emergency scenarios.

#### Scenario: Mongo-backed configuration exists for a survey-driven flow
- **WHEN** the runtime resolves a survey-driven access point with valid catalog references in Mongo
- **THEN** the Clinical Writer MUST use the Mongo-backed prompt and persona definitions for that request
- **AND** it MUST not require Google Drive availability for the request to succeed
