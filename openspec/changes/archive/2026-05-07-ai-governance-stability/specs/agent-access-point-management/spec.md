# agent-access-point-management Specification (Delta)

## MODIFIED Requirements

### Requirement: Agent Access Points MUST resolve provider and model
The system SHALL support explicit binding of an access point to a specific provider (e.g. glm, gemini) and model name.

#### Scenario: Access point configures specific model
- **WHEN** an access point has a specific model assigned in the Builder
- **THEN** the backend MUST prioritize this model over Global Settings and Environment defaults
- **AND** it MUST correctly propagate these parameters to the Clinical Writer API

#### Scenario: Access point omits model binding
- **WHEN** an access point does not have a specific model assigned (Global Default)
- **THEN** the system MUST resolve missing fields from the Global AI Configuration in MongoDB
- **AND** only if Global AI Configuration is missing, fall back to environment variables

### Requirement: Agent Access Point contracts MUST use only aiConfig for AI settings
The platform MUST retire legacy flat AI fields in access-point contracts and runtime resolution.

#### Scenario: Admin saves access point AI settings
- **WHEN** an admin creates or updates AI settings for an access point
- **THEN** the payload MUST use `aiConfig` as the only AI settings container
- **AND** retired flat fields (`aiProvider`, `glmModel`, `geminiModel`) MUST NOT be used

#### Scenario: Access point selects global inheritance
- **WHEN** an admin marks an access point as "Use Global AI Settings"
- **THEN** the backend MUST not store per-access-point model overrides
- **AND** runtime MUST resolve values from the global singleton `aiConfig`
