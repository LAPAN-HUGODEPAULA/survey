## MODIFIED Requirements

### Requirement: AI parameter governance framework
The system SHALL manage core AI parameters at the access-point route level. Global AI settings SHALL NOT be used as the runtime inheritance layer for access-point model routing.

#### Scenario: Access point route parameters are applied
- **WHEN** a request is processed through an Agent Access Point with `aiConfig.agentRefs`
- **THEN** the system SHALL apply the parameters from the selected route entry
- **AND** it SHALL use the referenced AI agent's defaults only for route fields that are omitted

#### Scenario: Access point omits route parameters
- **WHEN** an Agent Access Point route omits optional AI parameters such as `temperature`
- **THEN** the system SHALL apply the selected AI agent's configured defaults when available
- **AND** it SHALL NOT resolve missing values from `global_ai_config`
