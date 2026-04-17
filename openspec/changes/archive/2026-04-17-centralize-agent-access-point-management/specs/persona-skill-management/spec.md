## ADDED Requirements

### Requirement: Persona skills MUST be referenceable from access-point configuration
The persona-skill catalog MUST support stable runtime references from access-point definitions and MUST preserve referential integrity for those bindings.

#### Scenario: Persona skill is selected for an access point
- **WHEN** an administrator selects a persona skill while configuring an access point
- **THEN** the system MUST store the selected `personaSkillKey` as part of that access-point definition
- **AND** the saved binding MUST be available for runtime resolution on the next eligible request

#### Scenario: Admin attempts to delete a bound persona skill
- **WHEN** an administrator tries to delete a persona skill that is referenced by an access point
- **THEN** the system MUST reject the deletion
- **AND** it MUST explain that the persona skill is still required by runtime configuration
