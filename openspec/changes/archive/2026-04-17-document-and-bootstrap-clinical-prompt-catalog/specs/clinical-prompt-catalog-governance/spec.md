## ADDED Requirements

### Requirement: The platform MUST document the Clinical Writer prompt stack taxonomy
The platform MUST maintain detailed documentation that explains the role, required fields, and authoring boundaries for questionnaire prompts, persona skills, output profiles, and agent access points.

#### Scenario: Admin needs to understand where a new instruction belongs
- **WHEN** an administrator or developer needs to add or revise Clinical Writer behavior
- **THEN** the documentation MUST explain whether the instruction belongs in a questionnaire prompt, persona skill, output profile, or access-point configuration
- **AND** it MUST provide examples of correct decomposition boundaries

### Requirement: The platform MUST provide a Portuguese admin runbook for prompt operations
The system documentation set MUST include a Portuguese runbook that explains how the designated admin registers, reviews, updates, and validates prompt-catalog records in `survey-builder`.

#### Scenario: Admin prepares to register a new prompt
- **WHEN** the builder administrator needs to create or revise a prompt-related catalog entry
- **THEN** the Portuguese runbook MUST describe the required inputs, review checklist, and validation steps
- **AND** it MUST explain how to avoid PHI, unsafe examples, and catalog-boundary mistakes during registration

### Requirement: The platform MUST maintain a bootstrap prompt catalog plan
The system MUST maintain a documented bootstrap pack that decomposes the current prompt inventory into starter questionnaire prompts, persona skills, output profiles, and access-point defaults suitable for later publication.

#### Scenario: Team reviews the initial prompt inventory
- **WHEN** the team evaluates the documented bootstrap catalog
- **THEN** the material MUST identify each proposed starter record, its intended purpose, and its source prompt lineage
- **AND** it MUST clearly distinguish reviewed starter content from unpublished draft material
