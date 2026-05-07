## ADDED Requirements

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
