# agent-access-point-management Specification

## Purpose
Define how Agent Access Points resolve and apply AI provider and model configurations.
## Requirements
### Requirement: Agent Access Points MUST resolve provider and model
The system SHALL support explicit binding of an access point to an ordered list of AI agent route entries. Each route entry SHALL reference an AI agent catalog record and MAY override the model and request parameters for that access point.

#### Scenario: Access point configures ordered agent route
- **WHEN** an access point has `aiConfig.agentRefs` assigned in the Builder
- **THEN** the backend MUST prioritize the first enabled route entry as the primary runtime model
- **AND** it MUST propagate the ordered enabled route entries to the Clinical Writer API

#### Scenario: Access point configures fallbacks
- **WHEN** an access point has multiple enabled `agentRefs`
- **THEN** the runtime MUST attempt the route entries in stored order
- **AND** it MUST treat entries after the first enabled entry as fallback agents

#### Scenario: Access point uses legacy model binding during migration
- **WHEN** an access point has legacy `primaryProvider` and `primaryModel` fields but does not have `agentRefs`
- **THEN** the backend MUST continue resolving the legacy fields for backward-compatible execution
- **AND** new Builder writes MUST persist `agentRefs` instead of legacy provider/model pairs

### Requirement: Agent Access Point contracts MUST use only aiConfig for AI settings
The platform MUST use `aiConfig` as the only access-point AI settings container and MUST store ordered agent routing inside that container.

#### Scenario: Admin saves access point AI settings
- **WHEN** an admin creates or updates AI settings for an access point
- **THEN** the payload MUST use `aiConfig.agentRefs` as the route definition
- **AND** retired flat fields (`aiProvider`, `glmModel`, `geminiModel`) MUST NOT be used

#### Scenario: Access point has no route entries
- **WHEN** an access point is saved without enabled `aiConfig.agentRefs`
- **THEN** the backend MUST reject the access point AI configuration unless a legacy configuration is being read during migration
- **AND** the runtime MUST NOT invent a global model selection

