# ai-model-configuration Specification

## Purpose
Define how agent access points configure AI provider, model, and sampling parameters so runtime model selection can be managed from the builder without code changes.
## Requirements
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

