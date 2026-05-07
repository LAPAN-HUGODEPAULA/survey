# orchestrator-prompt-overrides Specification

## Purpose
Define how orchestrator-level system and formatting prompts can be overridden per access point, while preserving safe fallback behavior in clinical writer runtime.

## Requirements

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
