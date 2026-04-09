## ADDED Requirements

### Requirement: The system MUST provide a dedicated persona skill catalog screen in survey-builder.

The `survey-builder` application MUST expose persona skill management as a dedicated administrative flow reachable from the main survey administration screen. The catalog MUST load persona skills from the existing backend API and render them using the shared Flutter design system and established survey-builder CRUD patterns.

#### Scenario: User opens the persona skill catalog
- **Given** the user is on the main `survey-builder` screen
- **When** they choose the persona skill management action
- **Then** the application MUST navigate to a dedicated persona skill catalog screen
- **And** it MUST request persona skills from `GET /persona_skills/`
- **And** it MUST display the returned persona skills in a list

### Requirement: The system MUST allow users to create and edit persona skills.

The persona skill form MUST let administrators create and update persona skills with the fields `personaSkillKey`, `name`, `outputProfile`, and `instructions`. The form MUST enforce required fields and the same key-format constraints used by the backend before submitting writes.

#### Scenario: User creates a persona skill
- **Given** the user is managing persona skills in `survey-builder`
- **When** they submit a valid `personaSkillKey`, `name`, `outputProfile`, and `instructions`
- **Then** the application MUST create the persona skill through `POST /persona_skills/`
- **And** it MUST show the saved persona skill in the catalog

#### Scenario: User edits an existing persona skill
- **Given** a persona skill already exists in the catalog
- **When** the user updates its editable fields and saves
- **Then** the application MUST persist the changes through `PUT /persona_skills/{personaSkillKey}`
- **And** it MUST show the updated persona skill in the catalog

#### Scenario: User enters an invalid key format
- **Given** the user is filling the persona skill form
- **When** `personaSkillKey` or `outputProfile` contains characters outside lowercase letters, digits, colon, underscore, or hyphen
- **Then** the application MUST block submission
- **And** it MUST show a validation error that explains the allowed format

#### Scenario: User submits a duplicate persona key or output profile
- **Given** the catalog already contains a persona skill with the same `personaSkillKey` or `outputProfile`
- **When** the user tries to save a conflicting persona skill
- **Then** the application MUST surface the duplicate conflict clearly in the UI
- **And** it MUST identify whether the conflict is on `personaSkillKey` or `outputProfile`

### Requirement: The system MUST allow users to delete persona skills.

The persona skill catalog MUST allow administrators to remove persona skills through the existing backend API and MUST protect that action with a confirmation step.

#### Scenario: User deletes a persona skill
- **Given** the user is viewing the persona skill catalog
- **When** they confirm deletion for a specific persona skill
- **Then** the application MUST call `DELETE /persona_skills/{personaSkillKey}`
- **And** it MUST remove that persona skill from the displayed catalog
