# persona-skill-management Specification

## Purpose
TBD - created by archiving change refactor-clinical-writer-prompt-storage. Update Purpose after archive.
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

Each `PersonaSkills` document MUST have a unique stable key, a declared output profile, and non-empty persona instructions. Editing a persona skill MUST be treated as an operational configuration change rather than a code change.

#### Scenario: Reject a duplicate persona skill key
- **Given** a persona skill already exists with a given stable key
- **When** another persona skill is created or updated to use the same key
- **Then** the system MUST reject the request with a validation error

#### Scenario: Update the school report tone
- **Given** a persona skill exists for the school report output profile
- **When** a physician edits its persona instructions in MongoDB
- **Then** the system MUST persist the updated persona skill version
- **And** the updated document MUST be available for the next eligible runtime request

