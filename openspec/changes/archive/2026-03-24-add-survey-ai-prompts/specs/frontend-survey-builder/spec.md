## ADDED Requirements
### Requirement: The system MUST provide a user interface for managing reusable AI prompts.

The `survey-builder` application MUST let administrators create, edit, list, and remove reusable survey prompts that can later be associated with questionnaires.

#### Scenario: User creates a reusable prompt
- **Given** the user is managing reusable AI prompts in `survey-builder`
- **When** they submit a prompt name, `promptKey`, `outcomeType`, and prompt text
- **Then** the application MUST create the prompt through the backend API
- **And** it MUST show the saved prompt in the prompt catalog

#### Scenario: User edits a reusable prompt
- **Given** a reusable prompt already exists
- **When** the user changes its metadata or prompt text and saves
- **Then** the application MUST update the prompt through the backend API
- **And** it MUST show the updated prompt details in the prompt catalog

#### Scenario: User attempts to delete a prompt still in use
- **Given** a prompt is still associated with a questionnaire
- **When** the user tries to delete it from the builder UI
- **Then** the application MUST show the backend rejection
- **And** it MUST explain that the prompt must be detached from questionnaires first

### Requirement: The system MUST allow users to associate outcome prompts while editing a survey.

The survey form MUST let the user attach one reusable prompt for each desired report outcome available on that questionnaire.

#### Scenario: User associates prompts to a survey
- **Given** the user is editing a survey in `survey-builder`
- **And** reusable prompts exist in the prompt catalog
- **When** the user selects one or more prompts to associate with that survey and saves
- **Then** the application MUST include those prompt associations in the survey create or update request
- **And** it MUST preserve them when the survey is reopened for editing

#### Scenario: User attempts to assign two prompts with the same outcome type
- **Given** the user is editing a survey
- **When** they configure more than one prompt for the same `outcomeType`
- **Then** the application MUST prevent the save or show a validation error
