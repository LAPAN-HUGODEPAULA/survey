## ADDED Requirements

### Requirement: Prompt governance documentation MUST prohibit PHI and unsafe examples in authoring materials
Prompt-authoring documentation, bootstrap packs, and the builder admin runbook MUST instruct operators to avoid storing PHI, secrets, or unsafe sample data in prompts, examples, and seed materials.

#### Scenario: Admin consults the runbook before registering a prompt
- **WHEN** the admin reads the prompt-registration runbook
- **THEN** the guidance MUST explicitly prohibit copying real patient identifiers or unnecessary sensitive payloads into prompt content or examples
- **AND** it MUST provide safe alternatives such as synthetic examples and placeholder references
