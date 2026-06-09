## ADDED Requirements

### Requirement: Survey Builder MUST manage the AI agent catalog
The `survey-builder` application SHALL provide an administrative interface for listing, creating, editing, disabling, and deleting AI agent catalog records through builder-protected backend APIs.

#### Scenario: Admin lists AI agents
- **WHEN** an authorized builder admin opens the AI agent catalog screen
- **THEN** the application MUST request AI agents from the backend
- **AND** it MUST display each agent's name, provider type, default model, enabled state, and endpoint summary

#### Scenario: Admin edits an agent secret reference
- **WHEN** an authorized builder admin edits an AI agent
- **THEN** the form MUST accept an environment variable name for the API key
- **AND** it MUST NOT display or submit any raw API key value

### Requirement: Survey Builder MUST configure ordered access-point agent routes
The access-point form SHALL allow administrators to assign, reorder, enable, disable, and parameterize AI agent route entries for each access point.

#### Scenario: Admin configures local primary and remote fallback
- **WHEN** an authorized builder admin configures an access point with local Qwen first and Gemini second
- **THEN** the saved access point payload MUST include ordered `aiConfig.agentRefs`
- **AND** the UI MUST preserve the route order when the access point is reopened

#### Scenario: Admin saves invalid route
- **WHEN** an access-point route references a missing or disabled AI agent without explicitly disabling that route entry
- **THEN** the Builder UI MUST surface a validation error from the backend
- **AND** it MUST NOT silently replace the route with a different agent
