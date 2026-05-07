# clinical-writer-provider-routing Specification

## Purpose
Define the multi-provider routing strategy and execution policies for the Clinical Writer service, ensuring high availability and cost-effective model usage through automated fallback.

## Requirements

### Requirement: Clinical Writer MUST support GLM primary and Gemini fallback provider routing
The Clinical Writer service MUST support multi-provider routing for LLM invocation where GLM is attempted first and Gemini is attempted second when the primary invocation fails.

#### Scenario: Primary GLM call succeeds
- **WHEN** a request is executed with GLM configured as the primary provider
- **THEN** the service MUST return the GLM result without invoking Gemini

#### Scenario: Primary GLM call fails
- **WHEN** a request is executed with GLM configured as the primary provider and GLM raises an error
- **THEN** the service MUST invoke Gemini as fallback for the same prompt
- **AND** it MUST continue the workflow using the fallback response when valid

#### Scenario: GLM invocation is executed safely from an async request context
- **WHEN** the provider router invokes GLM while the FastAPI request stack already has a running event loop
- **THEN** the GLM invocation path MUST complete without calling `asyncio.run(...)`
- **AND** it MUST either return a valid GLM response or raise a provider error handled by fallback logic

### Requirement: Provider clients MUST use configured endpoints and credentials
The GLM client MUST call `https://api.z.ai/api/paas/v4/` with bearer-token authorization using `GLM_API_KEY`, and Gemini client MUST use `GEMINI_API_KEY`.

#### Scenario: GLM credentials and endpoint are configured
- **WHEN** the GLM provider client is created
- **THEN** the client MUST use the configured GLM API key
- **AND** it MUST target the Z.AI base endpoint

#### Scenario: GLM client runtime mode is synchronous
- **WHEN** `GLMClient.invoke()` is executed
- **THEN** it MUST use a synchronous OpenAI-compatible client invocation path
- **AND** it MUST NOT depend on `AsyncOpenAI` or coroutine execution wrappers inside `invoke()`

### Requirement: Clinical Writer MUST expose the effective model used
The service MUST record and expose the effective model/provider used for successful generation, including fallback executions.

#### Scenario: Fallback provider completes the request
- **WHEN** the primary provider fails and fallback succeeds
- **THEN** the reported model version metadata MUST identify the fallback model used
