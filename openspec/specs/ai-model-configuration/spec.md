# ai-model-configuration Specification

## Purpose
Define how agent access points configure AI provider, model, and sampling parameters so runtime model selection can be managed from the builder without code changes.

## Requirements

### Requirement: The Agent Access Point SHALL provide comprehensive AI model configuration
The system SHALL expose detailed model settings (Provider, Model Name, Temperature) for each Agent Access Point in the `survey-builder` administrative interface.

#### Scenario: Admin configures primary and fallback models
- **WHEN** an authorized admin selects a Primary Provider (e.g., 'gemini') and Model (e.g., 'gemini-1.5-pro') in the access point form
- **AND** optionally selects a Fallback Provider and Model
- **THEN** the system MUST persist these settings in the `aiConfig` block of the access point
- **AND** the AI runtime MUST attempt to use the Primary model first, followed by the Fallback model on failure

#### Scenario: Admin configures sampling temperature
- **WHEN** an authorized admin adjusts the temperature slider in the access point form
- **THEN** the system MUST persist the selected temperature (between 0.0 and 1.0)
- **AND** the LLM client MUST be initialized with this temperature for requests using that access point

### Requirement: The survey-builder MUST provide a user-friendly AI configuration interface
The administrative interface SHALL provide clear, categorized controls for AI settings within the Access Point form, including searchable dropdowns for known models and intuitive sliders for numerical parameters.

#### Scenario: Admin interacts with AI configuration section
- **WHEN** an admin expands the "Configuração de IA" section in the access point form
- **THEN** the system MUST display fields for Primary Provider, Primary Model, Fallback Provider, Fallback Model, and Temperature
- **AND** it SHALL provide sensible defaults (e.g., Provider: 'gemini', Temperature: 0.0) if no configuration exists
