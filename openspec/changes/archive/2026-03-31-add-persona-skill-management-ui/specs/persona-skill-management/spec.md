## MODIFIED Requirements

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
