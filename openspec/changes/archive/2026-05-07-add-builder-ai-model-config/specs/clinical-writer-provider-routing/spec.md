## MODIFIED Requirements

### Requirement: Clinical Writer MUST support GLM primary and Gemini fallback provider routing
The Clinical Writer service MUST support multi-provider routing for LLM invocation where the primary and fallback providers and models are dynamically determined by the request configuration.

#### Scenario: Dynamic primary/fallback selection
- **WHEN** a request specifies `primary_provider="gemini"` and `primary_model="gemini-2.0-flash"`
- **THEN** the `ModelRouter` MUST initialize the primary client using these specific values
- **AND** it MUST attempt this primary provider first before falling back to any secondary provider

### Requirement: Provider clients MUST use configured endpoints and credentials
The GLM client MUST call its configured endpoint (defaulting to `https://api.z.ai/api/paas/v4/`) with bearer-token authorization, and the Gemini client MUST use the configured Gemini API key and model parameters.

#### Scenario: Client receives advanced parameters
- **WHEN** a provider client is initialized with a specific `temperature` or `reasoning_effort`
- **THEN** the client MUST apply these parameters to all subsequent `invoke` calls for that request
