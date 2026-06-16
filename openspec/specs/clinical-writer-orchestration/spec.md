# Clinical Writer Orchestration & Engine Specification

## Purpose
Consolidates the architecture of the FastAPI clinical report generation backend, model/provider routing, parameter management, input caching, and LangGraph-based reflection/retry loops.

## Requirements
### Requirement: Clinical Writer MUST use a modular state graph for document generation.

The LangGraph orchestration MUST be composed of distinct phases that operate on a shared, strictly typed `AgentState` defined with `TypedDict`. For the short-term optimized report-generation flow, the graph MUST execute phases in the following default order: Context Loading, Clinical Analysis, and Persona Writing, then terminate. The state contract MUST keep intermediate artifacts such as hydrated prompts, `clinical_facts`, generated report payloads, and model metadata independently inspectable.

#### Scenario: Orchestrating a clinical report generation in optimized mode
- **WHEN** a valid generation request is processed
- **THEN** the request MUST sequentially pass through `ContextLoader`, `ClinicalAnalyzer`, and `PersonaWriter`
- **AND** the graph MUST terminate after `PersonaWriter` in default mode

#### Scenario: Reflection stage is bypassed by default
- **WHEN** the optimized flow is active
- **THEN** the graph MUST NOT invoke `ReflectorNode` for that request path
- **AND** it MUST avoid rewrite loops that depend on reflection iteration counters

#### Scenario: Preserving the graph factory used by FastAPI services
- **WHEN** the orchestration is updated to bypass reflection in default mode
- **THEN** the graph factory surface MUST remain compatible with existing `create_graph(...)` and `clinical_writer_graph` usage
- **AND** callers MUST NOT be required to change how they obtain or invoke the compiled graph

### Requirement: Clinical Analyzer MUST produce structured facts without narrative prose.

The analysis node MUST process input data strictly using clinical logic and MUST output a structured JSON object (`clinical_facts`). It MUST consume the source content together with the hydrated `interpretation_prompt` and MUST NOT generate natural language narrative intended for the end-user or persona-specific formatting.

#### Scenario: Analyzing visual hypersensitivity responses
- **Given** an input JSON containing severe photophobia responses
- **And** the state already contains the `interpretation_prompt` resolved for that questionnaire
- **When** the `ClinicalAnalyzer` processes the data
- **Then** the output MUST be a JSON object like `{"photophobia_severity": "severe"}`
- **And** the output MUST NOT contain full sentences such as "The patient presents with severe photophobia."

### Requirement: Persona Writer MUST consume structured facts to generate styled Markdown.

The writing node MUST rely on the `clinical_facts` produced by the Analyzer together with the hydrated persona instructions. It MUST generate the final report output from those structured facts and MUST NOT depend on monolithic prompt text or direct clinical reinterpretation of the raw request content as its primary source of truth.

#### Scenario: Writing a school report from facts
-   **Given** a `clinical_facts` object indicating moderate visual distress
-   **And** a persona configured for pedagogical (school) tone
-   **When** the `PersonaWriter` generates the report
-   **Then** the resulting output MUST use accessible language appropriate for educators
-   **And** it MUST NOT contradict the severity facts provided by the Analyzer.

### Requirement: Layered graph nodes MUST use provider-aware routing consistently
The active LLM stages in the optimized layered flow MUST use the same provider-aware routing policy so primary/fallback behavior is consistent across clinical analysis and persona writing.

#### Scenario: Request runs through active graph stages
- **WHEN** a clinical writer request passes through analyzer and writer stages
- **THEN** each active stage MUST resolve LLM invocations through provider-aware primary/fallback routing

### Requirement: Reflection stage MUST use the same provider chain policy
When reflection is explicitly enabled in a future or rollback path, the reflection stage MUST apply the same primary/fallback provider behavior as report generation stages.

#### Scenario: Reflector primary provider fails when reflection is enabled
- **WHEN** reflection is enabled and the reflector primary provider invocation fails
- **THEN** the reflector MUST invoke the fallback provider
- **AND** it MUST continue evaluation using the fallback response when valid

### Requirement: Clinical Writer MUST review generated reports with a dedicated reflection node before final delivery.

The clinical writer pipeline MUST execute a dedicated `ReflectorNode` after report generation to evaluate whether the draft is safe and appropriate for the target audience. The node MUST produce a structured review outcome indicating PASS or FAIL, and MUST provide corrective feedback when the draft is rejected.

#### Scenario: Reflection approves a safe audience-appropriate report
- **WHEN** the `ReflectorNode` evaluates a generated report whose tone matches the target audience and whose content satisfies the configured safety checks
- **THEN** the node MUST emit a PASS decision
- **AND** the graph MUST allow the report to proceed to final delivery without another writing pass

### Requirement: Clinical Writer MUST reject non-medical reports that contain invasive medical recommendations.

For non-medical output profiles, including school-facing reports, the `ReflectorNode` MUST reject drafts that contain prescriptions, invasive medical recommendations, or clinical directions inappropriate for the target audience.

#### Scenario: School report contains a prescription
- **GIVEN** a generated report for a school-facing output profile
- **AND** the report contains a medical prescription or invasive recommendation
- **WHEN** the `ReflectorNode` evaluates the draft
- **THEN** it MUST emit a FAIL decision
- **AND** it MUST include corrective feedback instructing the writer to remove the invasive medical guidance and rewrite the report for the school audience

### Requirement: Clinical Writer MUST enforce tone validation for the intended audience.

The `ReflectorNode` MUST validate that the generated report uses tone, vocabulary, and level of instruction appropriate for the configured audience profile.

#### Scenario: Report tone is too clinical for a school audience
- **GIVEN** a generated report for a pedagogical or school-facing profile
- **WHEN** the `ReflectorNode` detects tone that is overly medical, prescriptive, or otherwise inconsistent with the audience
- **THEN** it MUST emit a FAIL decision
- **AND** it MUST instruct the writer to adjust the tone to match the intended recipient

### Requirement: Clinical Writer MUST cap reflection-driven rewrite loops.

The reflection workflow MUST allow at most 2 corrective rewrite iterations after the initial draft. If the draft still fails review after the configured limit, the system MUST stop retrying and surface an actionable failure instead of looping indefinitely.

#### Scenario: Draft never converges after repeated reflection failures
- **GIVEN** a report draft fails reflection repeatedly
- **WHEN** the workflow reaches the second corrective rewrite and the next reflection still fails
- **THEN** the graph MUST stop the reflection loop
- **AND** it MUST surface an actionable failure indicating that safe convergence was not achieved within the allowed iterations

### Requirement: Limited Retries for AI Jobs
The background worker SHALL limit the number of processing attempts for a single document to prevent infinite token consumption.

#### Scenario: Document fails repeatedly
- **WHEN** a survey response processing fails and reaches `WORKER_MAX_RETRIES`
- **THEN** the system MUST increment the `retryCount` up to the configured maximum
- **AND** it MUST set the `agentResponseStatus` to `permanently_failed`
- **AND** it MUST stop polling this document for automatic processing

#### Scenario: Debug mode retry limit is reduced
- **WHEN** the environment sets `WORKER_MAX_RETRIES=1`
- **THEN** the worker MUST stop automatic retries after the first failed attempt

### Requirement: Failure Context Recording
The system SHALL record the reason for failure to aid in administrative diagnosis.

#### Scenario: Processing failure
- **WHEN** the `survey-worker` encounters an error while calling the Clinical Writer
- **THEN** it MUST store the error message in the `lastError` field of the document
- **AND** update the `agentResponseUpdatedAt` timestamp

### Requirement: Worker diagnostics logging MUST be runtime-configurable
The worker SHALL provide runtime flags to enable or disable detailed payload and response logging without recompilation.

#### Scenario: Payload and response logging enabled for investigation
- **WHEN** diagnostic logging flags are enabled
- **THEN** the worker MUST log outbound agent payload, raw agent response, and normalized response
- **AND** the worker MUST include failure context with request identifiers to aid debugging malformed responses

#### Scenario: Payload and response logging disabled
- **WHEN** diagnostic logging flags are disabled
- **THEN** the worker MUST keep concise operational logs without verbose payload dumps

### Requirement: Clinical Writer SHALL support input caching for cost optimization
The Clinical Writer service SHALL implement LLM input caching (context caching) to reduce token consumption for repetitive clinical analysis tasks. It SHALL support sending provider-specific caching headers or parameters when enabled in the request configuration.

#### Scenario: Input caching is enabled for a request
- **WHEN** a `ProcessRequest` is received with `enable_caching=true`
- **THEN** the system SHALL include caching-related parameters (e.g., `cache_id` or provider headers) in the downstream LLM call
- **AND** it SHALL log whether the request was eligible for caching

### Requirement: Clinical Writer SHALL support advanced model parameters
The service SHALL support passing advanced parameters like `reasoning_effort` and `temperature` to the underlying LLM providers.

#### Scenario: Reasoning effort is configured
- **WHEN** a request includes `reasoning_effort="high"`
- **THEN** the GLM/Gemini client SHALL map this to the provider-specific parameter (e.g., `extra_body={"thinking": {"type": "enabled"}}` for GLM or reasoning parameters for Gemini)
- **AND** it SHALL apply the specified `temperature` if provided

### Requirement: The Agent Access Point SHALL provide comprehensive AI model configuration
The system SHALL expose detailed model settings for each Agent Access Point in the `survey-builder` administrative interface through ordered AI agent route entries.

#### Scenario: Admin configures primary and fallback models
- **WHEN** an authorized admin selects one or more AI agents and model overrides in the access point form
- **THEN** the system MUST persist these settings in the `aiConfig.agentRefs` block of the access point
- **AND** the AI runtime MUST attempt enabled route entries in stored order

#### Scenario: Admin configures sampling temperature
- **WHEN** an authorized admin adjusts the temperature for a route entry in the access point form
- **THEN** the system MUST persist the selected temperature between 0.0 and 1.0 for that route entry
- **AND** the LLM client MUST be initialized with this temperature for requests using that route entry

### Requirement: The survey-builder MUST provide a user-friendly AI configuration interface
The administrative interface SHALL provide clear, categorized controls for AI settings within the Access Point form, including agent selection from the catalog, model override input, route ordering controls, and intuitive sliders for numerical parameters.

#### Scenario: Admin interacts with AI configuration section
- **WHEN** an admin opens the "Configuração de IA" section in the access point form
- **THEN** the system MUST display ordered agent route controls instead of hardcoded GLM/Gemini provider dropdowns
- **AND** it SHALL provide sensible defaults from the selected agent catalog record when a route entry has no model override

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

### Requirement: The system SHALL support dynamic orchestrator prompt overrides via Agent Access Points
The platform SHALL allow administrators to override the default hardcoded system and formatting prompts used by the AI agents by defining these overrides within the Agent Access Point configuration.

#### Scenario: Admin configures system prompt override
- **WHEN** an authorized admin sets a `systemPromptOverride` value in an Agent Access Point
- **THEN** the system MUST persist this override with the access point record
- **AND** the AI orchestrator MUST use this specific instruction set instead of the default `MEDICAL_RECORD_PROMPT` for subsequent requests using that access point

#### Scenario: Admin configures format prompt override
- **WHEN** an authorized admin sets a `formatPromptOverride` value in an Agent Access Point
- **THEN** the system MUST persist this override with the access point record
- **AND** the AI orchestrator MUST use this specific instruction set instead of the default `JSON_PROMPT` for subsequent requests using that access point

### Requirement: Clinical Writer API MUST prioritize request-level prompt overrides
The AI processing service SHALL accept optional `system_prompt_override` and `format_prompt_override` fields in its processing request and MUST use them if provided.

#### Scenario: API request includes prompt overrides
- **WHEN** the `clinical-writer-api` receives a `/process` request containing `system_prompt_override`
- **THEN** the `ContextLoader` and relevant agent nodes MUST use the provided string as the system instruction
- **AND** it MUST NOT fall back to the hardcoded internal constants for that specific request execution

### Requirement: Clinical Writer Integration Components

The survey backend SHALL implement Clinical Writer integration as composable endpoint, health, run-submission, response-normalization, and formatting components.

#### Scenario: Submission success

- GIVEN a valid Clinical Writer /process response, WHEN the integration submits a report request, THEN it MUST return a typed success result with report content and relevant progress metadata.

#### Scenario: Submission failure

- GIVEN a timeout, quota error, invalid JSON, or unreachable service, WHEN the integration submits a report request, THEN it MUST return a typed failure result without leaking secrets or raw clinical payloads into logs.

### Requirement: Report Text Formatting Reuse

Report-to-text conversion SHALL be implemented once per shared backend boundary rather than duplicated across integration clients and routes.

#### Scenario: Nested report content

- GIVEN a structured report with nested sections and list values, WHEN text formatting runs, THEN output MUST be deterministic and preserve clinically relevant text without O(N^2) traversal on normal inputs.

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

### Requirement: Centralized Global AI Configuration
The system SHALL maintain a global configuration for AI model defaults that applies when no specific override exists at the Access Point level.

#### Scenario: Admin updates global AI model
- **WHEN** an authorized admin updates the Primary Model in the "Configurações Globais" screen
- **THEN** all subsequent AI requests that do not have an explicit model override MUST use the new global model
- **AND** the system MUST persist this change as a singleton Mongo document using `aiConfig` fields

### Requirement: Configuration Hierarchy for AI Models
The system MUST resolve AI configuration using the following priority:
1. Request-level payload overrides (e.g. manual API test).
2. Agent Access Point specific configuration.
3. Global AI Configuration (from MongoDB).
4. Environment variables / System defaults (last resort).

#### Scenario: Access Point lacks configuration
- **WHEN** a request uses an Access Point that has "Global Default" selected for its model
- **THEN** the system MUST fetch and apply the model from the Global AI Configuration

### Requirement: Global and Access Point configuration MUST share one schema
The platform MUST represent AI settings with a single `aiConfig` structure across global settings, access points, and runtime payloads.

#### Scenario: Runtime builds effective AI configuration
- **WHEN** the backend computes effective AI parameters for a request
- **THEN** it MUST use only `aiConfig` fields (`primaryProvider`, `primaryModel`, `fallbackProvider`, `fallbackModel`, `temperature`, `reasoningEffort`, `enableCaching`)
- **AND** it MUST NOT rely on retired flat fields (`aiProvider`, `glmModel`, `geminiModel`)
