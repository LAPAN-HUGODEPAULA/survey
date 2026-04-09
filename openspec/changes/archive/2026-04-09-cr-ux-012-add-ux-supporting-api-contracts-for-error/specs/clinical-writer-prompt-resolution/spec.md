## MODIFIED Requirements

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
