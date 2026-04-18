# persona-skill-management Specification

## Purpose
This specification defines how output-profile persona instructions are stored, validated, and operationally managed for Clinical Writer prompt composition.
## Requirements
### Requirement: The system MUST provide a MongoDB-backed PersonaSkills catalog for output-profile style and restrictions.

The system MUST store output-profile persona definitions in a dedicated `PersonaSkills` collection. Each persona skill MUST describe the tone, audience expectations, style constraints, or safety restrictions for one runtime output profile.

#### Scenario: Create a persona skill for school reports
- **Given** an administrator is configuring the tone for the school report output profile
- **When** they create a `PersonaSkills` document with a stable persona key, an output-profile binding, and persona instructions
- **Then** the system MUST persist the persona skill in MongoDB
- **And** it MUST make that persona skill available for runtime resolution

#### Scenario: List persona skills
- **Given** persona skills exist in the system
- **When** an administrative client requests the persona skill catalog
- **Then** the system MUST return the stored persona skill definitions
- **And** each definition MUST remain independent from questionnaire-specific clinical logic

### Requirement: Persona skills MUST be uniquely identifiable and editable as operational configuration.

Each `PersonaSkills` document MUST have a unique stable key, a unique declared output profile, and non-empty persona instructions. Editing a persona skill MUST be treated as an operational configuration change rather than a code change, and administrators MUST be able to remove obsolete persona skills from the catalog.

#### Scenario: Reject a duplicate persona skill key
- **Given** a persona skill already exists with a given stable key
- **When** another persona skill is created or updated to use the same key
- **Then** the system MUST reject the request with a validation error

#### Scenario: Reject a duplicate output profile
- **Given** a persona skill already exists for an output profile
- **When** another persona skill is created or updated to use that same `outputProfile`
- **Then** the system MUST reject the request with a validation error

#### Scenario: Update the school report tone
- **Given** a persona skill exists for the school report output profile
- **When** a physician edits its persona instructions in the operational catalog
- **Then** the system MUST persist the updated persona skill version
- **And** the updated document MUST be available for the next eligible runtime request

#### Scenario: Delete an obsolete persona skill
- **Given** a persona skill exists in the catalog
- **When** an administrator deletes that persona skill through the operational management interface
- **Then** the system MUST remove it from the catalog

### Requirement: Persona-skill governance MUST define authoring boundaries and starter records
The persona-skill documentation MUST define what belongs inside persona skills, how they relate to output profiles, and which starter persona skills are proposed for the initial bootstrap catalog.

#### Scenario: Admin reviews a persona skill draft
- **WHEN** an administrator evaluates a persona-skill candidate
- **THEN** the governance documentation MUST explain the expected output-style responsibilities and prohibited questionnaire-specific clinical logic
- **AND** it MUST show how the candidate maps to a documented starter persona skill or output profile

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
