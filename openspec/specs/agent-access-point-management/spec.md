# agent-access-point-management Specification

## Purpose
Define the configuration model and resolution logic for centralized agent access points that map stable keys to runtime prompt stacks (questionnaire prompts, persona skills, and output profiles).

## Requirements

### Requirement: The system MUST provide a builder-managed agent access-point catalog
The platform MUST provide a configuration model for agent access points that maps each stable access-point key to the runtime questionnaire prompt, persona skill, and output profile used for that entry point.

#### Scenario: Admin configures an access point
- **WHEN** an authorized builder admin creates or edits an agent access point
- **THEN** the system MUST persist a stable access-point key, human-readable name, target app or flow metadata, and the selected `promptKey`, `personaSkillKey`, and `outputProfile`
- **AND** the saved configuration MUST be available for runtime resolution

#### Scenario: Admin references a missing catalog entry
- **WHEN** an access-point configuration references a questionnaire prompt, persona skill, or output profile that does not exist
- **THEN** the system MUST reject the save with a validation error
- **AND** it MUST identify which referenced catalog entry is invalid

### Requirement: Access-point resolution MUST define a stable precedence order
When a runtime flow requests Clinical Writer output, the system MUST resolve the effective prompt stack using a documented precedence order that prioritizes explicit request overrides first, then access-point configuration, then survey defaults, and finally approved legacy fallback behavior.

#### Scenario: Access point overrides survey default
- WHEN a survey defines default prompt or persona settings and the requested access point defines different runtime bindings
- THEN the access-point configuration MUST win for that request
- AND the system MUST not silently fall back to the survey default unless the access-point binding is absent

### Requirement: Access-point catalog MUST persist provider and model bindings for clinical writer runtime
Each agent access point MUST persist a comprehensive `aiConfig` object that includes provider/model bindings, temperature, reasoning effort, and caching flags.

#### Scenario: Admin saves access-point AI configuration
- **WHEN** an authorized admin creates or updates an access point with an `aiConfig` block
- **THEN** the system MUST persist the `primaryProvider`, `primaryModel`, `fallbackProvider`, `fallbackModel`, `temperature`, `reasoningEffort`, and `enableCaching` fields
- **AND** these fields MUST be validated against allowed values (e.g., `reasoningEffort` must be one of "low", "medium", "high")

### Requirement: Access-point resolution MUST include provider and model precedence
Runtime access-point resolution MUST include provider/model selection with precedence: request override, access-point binding, system default setting.

#### Scenario: Access point defines explicit model binding
- **WHEN** a request references an access point that includes provider/model bindings
- **THEN** the resolved runtime configuration MUST use the access-point provider/model values
- **AND** it MUST not fall back to system defaults for fields explicitly set on the access point

#### Scenario: Access point omits model binding
- **WHEN** a request references an access point without provider/model bindings
- **THEN** the system MUST resolve missing fields from system default settings

