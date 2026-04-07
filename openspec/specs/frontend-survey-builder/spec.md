# frontend-survey-builder Specification

## Purpose
This specification defines the user interface and interactions for the `survey-builder` application, enabling administrators to manage clinical surveys and the operational prompt catalogs used by survey-driven report generation.
## Requirements
### Requirement: The system MUST provide a user interface for listing surveys.

This interface MUST serve as the main entry point of the application, presenting a comprehensive list of all available surveys and providing top-level actions like creation and navigation.

#### Scenario: User views the list of surveys
-   **Given** the user opens the `survey-builder` application
-   **When** the main screen loads
-   **Then** the app MUST call the `GET /surveys` API endpoint
-   **And** it MUST display the retrieved surveys in a list.
-   **And** each item in the list SHOULD show the survey title and provide options to "Edit" and "Delete".
-   **And** there MUST be a "Create New Survey" button visible on the screen.

### Requirement: The system MUST provide a user interface for creating and editing surveys.

This interface MUST provide the core functionality of the application: a form-based view to define the structure and content of a survey.

#### Scenario: User creates a new survey
-   **Given** the user is on the survey list screen
-   **When** they click the "Create New Survey" button
-   **Then** they ARE navigated to a new screen with a form for entering survey details.
-   **When** the user fills the form and clicks "Save"
-   **Then** the app MUST make a `POST` request to `/surveys` with the form data.
-   **And** upon success, it SHOULD navigate back to the survey list screen, showing the new survey.

#### Scenario: User edits an existing survey
-   **Given** the user is on the survey list screen
-   **When** they click the "Edit" button for a specific survey
-   **Then** they ARE navigated to a form screen, pre-filled with the details of the selected survey.
-   **When** the user modifies the data and clicks "Save"
-   **Then** the app MUST make a `PUT` request to `/surveys/{survey_id}` with the updated data.
-   **And** upon success, it SHOULD navigate back to the survey list screen, showing the updated survey.

### Requirement: The system MUST allow users to delete surveys.

To maintain data hygiene and lifecycle management, users MUST be able to remove surveys that are no longer needed. This action should be protected by a confirmation step to prevent accidental deletion.

#### Scenario: User deletes a survey
-   **Given** the user is on the survey list screen
-   **When** they click the "Delete" button for a specific survey
-   **Then** the app SHOULD show a confirmation dialog.
-   **When** the user confirms the deletion
-   **Then** the app MUST make a `DELETE` request to `/surveys/{survey_id}`.
-   **And** the survey MUST be removed from the list on the screen.

### Requirement: The application MUST have a consistent visual style.

To ensure a cohesive user experience across the entire LAPAN Survey Platform, the new application MUST adopt the established visual identity.

#### Scenario: User opens the application
-   **Given** the `survey-builder` application is launched
-   **Then** the UI components, colors, and fonts MUST be consistent with the shared `design_system_flutter` package.
-   **And** the primary color scheme SHOULD be based on `Colors.orange`, consistent with the other apps.

### Requirement: The system MUST provide a rich text editor for specific survey fields.

To allow for more expressive and formatted content, the system MUST provide a WYSIWYG editor for certain text fields.

#### Scenario: User edits a survey with rich text fields
-   **Given** the user is on the survey editor screen
-   **Then** the fields for "Survey Description," "Preamble," and "Final Notes" MUST be rendered as rich text editors.
-   **When** the user enters formatted content (e.g., bold text, lists, links) and saves the survey
-   **Then** the corresponding data MUST be saved as HTML.

#### Scenario: User pastes unsafe HTML into the editor
-   **GIVEN** the rich text editor receives pasted or restored HTML content
-   **WHEN** the markup contains unsupported tags, event handlers, or dangerous
    link schemes
-   **THEN** the editor MUST strip unsupported markup before saving or
    re-rendering it
-   **AND** it MUST allow only safe formatting tags and approved link
    protocols

### Requirement: The system MUST allow users to reorder questions within a survey.

To provide flexibility in survey design, users MUST be able to change the order of questions.

#### Scenario: User reorders a question
-   **Given** the user is on the survey editor screen viewing a survey with multiple questions
-   **Then** each question item MUST display an "Up" and a "Down" arrow button.
-   **When** the user clicks the "Down" arrow for a question
-   **Then** the question MUST move one position down in the list.
-   **And** the UI MUST update to reflect the new order.
-   **When** the user clicks the "Up" arrow for a question
-   **Then** the question MUST move one position up in the list.
-   **And** the UI MUST update to reflect the new order.
-   **When** the user saves the survey
-   **Then** the new question order MUST be persisted.

### Requirement: The system MUST allow users to export all surveys.

To support data backup, migration, and external analysis, users MUST be able to export all survey data.

#### Scenario: User exports all surveys
-   **Given** the user is on the main survey list screen
-   **Then** a button labeled "Export Surveys" MUST be visible.
-   **When** the user clicks the "Export Surveys" button
-   **Then** the application MUST make a `GET` request to a new `/surveys/export` endpoint.
-   **And** the application MUST trigger a download of the returned JSON file containing all survey data.

### Requirement: The system MUST provide a user interface for managing reusable AI prompts.

The `survey-builder` application MUST let administrators create, edit, list, and remove reusable survey prompts that can later be associated with questionnaires.

#### Scenario: User creates a reusable prompt
- **Given** the user is managing reusable AI prompts in `survey-builder`
- **When** they submit a prompt name, `promptKey`, and prompt text
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

### Requirement: The system MUST allow users to associate exactly one clinical report prompt while editing a survey.

The survey form MUST let the user attach exactly one reusable prompt to be used for clinical report generation.

#### Scenario: User associates a prompt to a survey
- **Given** the user is editing a survey in `survey-builder`
- **And** reusable prompts exist in the prompt catalog
- **When** the user selects a prompt to associate with that survey and saves
- **Then** the application MUST include that prompt reference in the survey create or update request
- **And** it MUST preserve it when the survey is reopened for editing

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

### Requirement: The survey editor MUST allow administrators to configure default persona settings on a survey.

The `survey-builder` survey form MUST let administrators select a default `personaSkillKey` and `outputProfile` for each survey. The UI MUST persist those values through survey create and update requests and MUST reload them when an existing survey is reopened.

#### Scenario: User selects default persona settings for a survey
- **Given** persona skills exist in the catalog
- **When** the user edits a survey and selects a default persona skill and output profile
- **Then** the application MUST include those values in the survey create or update payload
- **And** it MUST show the saved settings when the survey is opened again

#### Scenario: User edits a survey without default persona settings
- **Given** a survey has no stored `personaSkillKey` or `outputProfile`
- **When** the user opens that survey in `survey-builder`
- **Then** the persona configuration controls MUST load with empty values
- **And** the rest of the survey editing flow MUST continue to work

#### Scenario: User selects an invalid or stale persona option
- **Given** a survey references a persona skill that no longer exists in the catalog
- **When** the user loads or saves that survey in `survey-builder`
- **Then** the application MUST surface a clear configuration error
- **And** it MUST NOT silently replace the missing persona with a different default

### Requirement: Builder exposes question label controls
The `survey-builder` questionnaire editor SHALL present a label input for each question and include that label in all question preview/listing rows so administrators understand how the patient radar will render the axis.

#### Scenario: Administrator edits a question label
- **WHEN** the user edits a question in `survey-builder` and supplies a new label
- **THEN** the application MUST include the label in the payload sent to the backend
- **AND** the label MUST appear in the question list or preview immediately after saving

### Requirement: Survey-builder MUST present administrative feedback in context
The `survey-builder` application MUST present administrative save, validation, conflict, delete, loading, and empty-state feedback through structured in-context feedback surfaces instead of relying only on raw snackbars.

#### Scenario: An administrator encounters a save or validation issue
- **WHEN** the user saves a catalog item or survey form and the operation returns a validation problem or a failed write
- **THEN** the application MUST show the problem in context with a defined severity and readable guidance
- **AND** the message MUST explain whether the user should correct input, retry, or review a conflict

#### Scenario: An administrative action succeeds
- **WHEN** the user completes a create, update, export, or delete action successfully
- **THEN** the application MUST provide a recognizable success state through the canonical feedback model
- **AND** the feedback MAY use a transient container only when the action does not require further interpretation

