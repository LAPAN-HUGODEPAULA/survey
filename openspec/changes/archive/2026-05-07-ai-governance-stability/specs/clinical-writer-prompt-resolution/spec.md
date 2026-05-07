# clinical-writer-prompt-resolution Specification (Delta)

## MODIFIED Requirements

### Requirement: Clinical Writer API MUST follow payload authority
The AI processing service SHALL strictly follow the AI configuration provided in the request payload (Primary/Fallback models, Providers, Temperature).

#### Scenario: Request payload provides model
- **WHEN** the Clinical Writer receives a processing request with an explicit `primary_model`
- **THEN** it MUST use that model for all processing nodes in the current request
- **AND** it MUST NOT fall back to the internal `AgentConfig` environment variables unless the payload fields are missing or null

### Requirement: Clinical Writer MUST act as executor-only for model policy
The Clinical Writer runtime MUST not implement independent provider/model selection policy outside the resolved request payload.

#### Scenario: Request includes resolved aiConfig
- **WHEN** the Clinical Writer receives a request with resolved AI settings
- **THEN** it MUST execute with those settings
- **AND** it MUST NOT substitute alternative provider/model values from retired runtime patterns

#### Scenario: Legacy flat fields are absent by design
- **WHEN** the request is validated
- **THEN** runtime behavior MUST rely on `aiConfig`-aligned fields only
- **AND** retired flat field patterns (`aiProvider`, `glmModel`, `geminiModel`) MUST NOT be required for execution
