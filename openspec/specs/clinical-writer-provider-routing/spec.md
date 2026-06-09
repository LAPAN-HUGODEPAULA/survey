# clinical-writer-provider-routing Specification

## Purpose
Define the multi-provider routing strategy and execution policies for the Clinical Writer service, ensuring high availability and cost-effective model usage through automated fallback.
## Requirements
### Requirement: Clinical Writer MUST support GLM primary and Gemini fallback provider routing
The Clinical Writer service MUST support ordered multi-agent routing for LLM invocation where agents, models, endpoints, credentials, and request parameters are dynamically determined from request `aiConfig.agentRefs` and the AI agent catalog.

#### Scenario: Dynamic ordered route selection
- **WHEN** a request specifies enabled `agentRefs` for `local_qwen`, `glm`, and `gemini`
- **THEN** the `ModelRouter` MUST initialize the primary client using the first enabled agent route
- **AND** it MUST attempt subsequent enabled route entries only if earlier attempts fail

#### Scenario: Legacy primary/fallback selection
- **WHEN** a request specifies legacy `primaryProvider` and `fallbackProvider` fields but no `agentRefs`
- **THEN** the `ModelRouter` MUST continue resolving those fields for backward compatibility
- **AND** it MUST expose the same effective model metadata as the new route path

### Requirement: Provider clients MUST use configured endpoints and credentials
Provider clients MUST use endpoint URLs, provider adapter types, model names, and API key environment variable references from the resolved AI agent catalog. The OpenAI-compatible adapter MUST call the configured `baseUrl` with bearer-token authorization.

#### Scenario: OpenAI-compatible client receives endpoint settings
- **WHEN** an agent route references an AI agent with `providerType=openai_compatible`, `baseUrl=https://lapan-ai.tailf9eac9.ts.net/v1`, and `apiKeyEnvVar=AI_API_KEY`
- **THEN** the executor MUST initialize an OpenAI-compatible client using that base URL
- **AND** it MUST read the bearer token from the `AI_API_KEY` environment variable

#### Scenario: Client receives advanced parameters
- **WHEN** a route entry supplies a specific `temperature`, `maxTokens`, or response-format setting supported by the agent
- **THEN** the client MUST apply those parameters to the invocation for that route entry

### Requirement: Clinical Writer MUST expose the effective model used
The service MUST record and expose the effective agent and model used for successful generation, including fallback executions.

#### Scenario: Fallback provider completes the request
- **WHEN** the primary agent fails and a fallback agent succeeds
- **THEN** the reported model version metadata MUST identify the fallback agent key and model used

