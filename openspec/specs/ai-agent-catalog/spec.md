# ai-agent-catalog Specification

## Purpose
TBD - created by archiving change configure-ai-agent-catalog. Update Purpose after archive.
## Requirements
### Requirement: System MUST maintain a configurable AI agent catalog
The system SHALL store executable AI agent endpoint definitions in MongoDB so administrators can add or update model servers without source-code changes.

#### Scenario: Admin creates an OpenAI-compatible local agent
- **WHEN** an authorized builder admin creates an AI agent with `providerType` set to `openai_compatible`, a `baseUrl`, an `apiKeyEnvVar`, and a `defaultModel`
- **THEN** the backend MUST persist the agent in the AI agent catalog
- **AND** the backend MUST return the saved record without exposing any API key value

#### Scenario: Admin disables an agent
- **WHEN** an authorized builder admin marks an AI agent as disabled
- **THEN** the backend MUST preserve the agent record
- **AND** runtime route resolution MUST skip that agent unless a future request explicitly supports disabled-agent diagnostics

### Requirement: AI agent secrets MUST be resolved by environment variable reference
The system SHALL store only secret references for AI agents and SHALL resolve API key values from the Clinical Writer runtime environment.

#### Scenario: Catalog stores API key reference
- **WHEN** an AI agent is saved with `apiKeyEnvVar` set to `AI_API_KEY`
- **THEN** MongoDB MUST store the string `AI_API_KEY`
- **AND** API responses MUST NOT include the corresponding environment value

#### Scenario: Runtime secret is missing
- **WHEN** the Clinical Writer executor attempts an enabled agent whose `apiKeyEnvVar` is not present in the environment
- **THEN** that agent attempt MUST fail with a configuration error
- **AND** fallback routing MUST continue to the next enabled agent when one is configured

### Requirement: AI agent catalog MUST expose model endpoint capabilities
The AI agent catalog SHALL record capabilities needed by the executor and Builder UI, including OpenAI chat completion compatibility, response-format support, and RAG support.

#### Scenario: Agent advertises OpenAI chat completions
- **WHEN** an agent has `supportsOpenAIChatCompletions` enabled
- **THEN** the executor MUST be able to invoke it through the OpenAI-compatible adapter using `/v1/chat/completions`
- **AND** the Builder UI MAY offer OpenAI-style request options supported by the current access-point schema

