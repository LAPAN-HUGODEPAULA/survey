# clinical-writer-prompt-resolution Specification Delta

## MODIFIED Requirements

### Requirement: Clinical Writer MUST resolve questionnaire prompts and persona skills from MongoDB for migrated survey flows.

The prompt resolution mechanism MUST fetch both the `QuestionnairePrompts` document and the `PersonaSkills` document from MongoDB and MUST inject them into the `AgentState` as distinct context variables (`interpretation_prompt` and `persona_prompt`) so that specialized nodes can consume them independently.

#### Scenario: Route prompts to specialized nodes
- **Given** a survey-derived request that specifies a questionnaire and an output profile
- **When** the `ContextLoader` phase of the graph executes
- **Then** the state MUST be hydrated with `interpretation_prompt` for the Clinical Analyzer
- **And** the state MUST be hydrated with `persona_prompt` for the Persona Writer
- **And** the nodes MUST NOT have cross-access to irrelevant prompt segments.
