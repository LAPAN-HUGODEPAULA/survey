## MODIFIED Requirements

### Requirement: Access-point catalog MUST persist provider and model bindings for clinical writer runtime
Each agent access point MUST persist a comprehensive `aiConfig` object that includes provider/model bindings, temperature, reasoning effort, and caching flags.

#### Scenario: Admin saves access-point AI configuration
- **WHEN** an authorized admin creates or updates an access point with an `aiConfig` block
- **THEN** the system MUST persist the `primaryProvider`, `primaryModel`, `fallbackProvider`, `fallbackModel`, `temperature`, `reasoningEffort`, and `enableCaching` fields
- **AND** these fields MUST be validated against allowed values (e.g., `reasoningEffort` must be one of "low", "medium", "high")
