# Survey & Questionnaire Authoring Flow Specification

## Purpose
Consolidates database management for surveys, full question/label editing, administrative productivity interfaces, and local draft persistence in survey-builder.

## Requirements
### Requirement: The system MUST provide an API for survey management.

This API MUST expose CRUD (Create, Read, Update, Delete) operations for surveys. It will be consumed by the `survey-builder` frontend application to enable survey administration. All endpoints must be properly authenticated and authorized.

#### Scenario: List all surveys
-   **Given** a user requests the list of surveys
-   **When** they make a `GET` request to `/surveys`
-   **Then** the system SHOULD return a `200 OK` status
-   **And** the response body MUST contain a JSON array of survey objects.

#### Scenario: Create a new survey
-   **Given** a user has valid survey data
-   **When** they make a `POST` request to `/surveys` with the survey data in the body
-   **Then** the system SHOULD return a `201 Created` status
-   **And** the response body MUST contain the newly created survey object, including its system-assigned ID.

#### Scenario: Retrieve a single survey
-   **Given** a valid survey ID exists
-   **When** a user makes a `GET` request to `/surveys/{survey_id}`
-   **Then** the system SHOULD return a `200 OK` status
-   **And** the response body MUST contain the corresponding survey object.

#### Scenario: Update an existing survey
-   **Given** a valid survey ID exists and the user has updated survey data
-   **When** they make a `PUT` request to `/surveys/{survey_id}` with the updated data
-   **Then** the system SHOULD return a `200 OK` status
-   **And** the response body MUST contain the updated survey object.

#### Scenario: Delete a survey
-   **Given** a valid survey ID exists
-   **When** a user makes a `DELETE` request to `/surveys/{survey_id}`
-   **Then** the system SHOULD return a `204 No Content` status.

#### Scenario: Attempt to retrieve a non-existent survey
-   **Given** a survey ID that does not exist
-   **When** a user makes a `GET` request to `/surveys/{invalid_survey_id}`
-   **Then** the system SHOULD return a `404 Not Found` status.

### Requirement: The survey management API MUST persist a single nullable prompt reference on each survey.

Survey payloads MUST allow questionnaires to reference exactly one reusable prompt so report-generation applications can discover the available AI outcome for that questionnaire.

Each prompt reference MUST expose:

- `promptKey`
- `name`

#### Scenario: Create a survey with a prompt reference
- **Given** a reusable prompt already exists in the prompt catalog
- **When** a user creates a survey and includes a prompt reference in the payload
- **Then** the system MUST persist that reference with the survey
- **And** the created survey response MUST include the stored prompt metadata

#### Scenario: Retrieve a survey with a prompt reference
- **Given** a survey has an associated prompt
- **When** a client requests that survey through the API
- **Then** the response MUST include the prompt metadata needed for report generation

#### Scenario: Reject unknown prompt references
- **Given** a survey payload references a `promptKey` that does not exist in the prompt catalog
- **When** the client submits the create or update request
- **Then** the system MUST reject the request with a validation error

### Requirement: The survey management API MUST persist nullable default persona configuration on each survey.

Survey payloads MUST support nullable survey-level default `personaSkillKey` and `outputProfile` values so administrators can configure the default persona behavior for report generation without requiring request-level overrides on every submission.

These fields MUST remain backward compatible for surveys that do not yet define persona configuration.

#### Scenario: Create a survey with default persona configuration
- **Given** a persona skill exists in the persona catalog
- **When** a user creates a survey with `personaSkillKey` and `outputProfile`
- **Then** the system MUST persist those default persona settings with the survey
- **And** the created survey response MUST include the stored values

#### Scenario: Create a survey without persona configuration
- **Given** a user creates a survey without default persona settings
- **When** the survey payload omits `personaSkillKey` and `outputProfile` or sends them as `null`
- **Then** the system MUST accept the request
- **And** the stored survey MUST remain compatible with current fallback behavior

#### Scenario: Reject an unknown survey persona reference
- **Given** a survey payload references a `personaSkillKey` that does not exist in the persona catalog
- **When** the client submits the create or update request
- **Then** the system MUST reject the request with a clear configuration error

### Requirement: Surveys persist question labels
The survey management API SHALL include an optional `label` for each question definition so the patient-facing UI and agent layers can show human-friendly names. Create and update requests MUST accept `questions[i].label`, and fetch responses MUST return the stored label along with the rest of the survey definition.

#### Scenario: Client saves a labeled question
- **WHEN** a client sends `questions[i].label` in a `POST /surveys` or `PUT /surveys/{id}` payload
- **THEN** the backend MUST store the provided label in MongoDB with the question data
- **AND** the subsequent `GET /surveys/{id}` response MUST include that label

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

This interface MUST provide the core functionality of the application: a form-based view to define the structure and content of a survey. The editor MUST include sectional wayfinding and persistent action areas to support long editing sessions.

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

#### Scenario: User navigates a long survey form
- **GIVEN** the user is editing a complex survey with multiple sections (Preamble, Instructions, Questions, Prompts, Personas)
- **WHEN** the user scrolls the page
- **THEN** a sectional navigation menu MUST remain visible to allow jumping between parts
- **AND** the "Save" and "Cancel" buttons MUST remain sticky and persistently accessible.

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
The `survey-builder` application MUST present administrative save, validation, conflict, delete, loading, and empty-state feedback through structured in-context feedback surfaces instead of relying only on raw snackbars. This MUST include form-level error summaries and inline field validation.

#### Scenario: An administrator encounters a save or validation issue
- **WHEN** the user saves a catalog item or survey form and the operation returns a validation problem or a failed write
- **THEN** the application MUST show a form-level error summary at the top of the editor
- **AND** it MUST show the problem in context with a defined severity and readable guidance (inline field errors)
- **AND** the message MUST explain whether the user should correct input, retry, or review a conflict

#### Scenario: An administrative action succeeds
- **WHEN** the user completes a create, update, export, or delete action successfully
- **THEN** the application MUST provide a recognizable success state through the canonical feedback model
- **AND** the feedback MAY use a transient container only when the action does not require further interpretation

### Requirement: Survey-builder MUST expose a dedicated admin login and blocked-access states
The `survey-builder` application MUST present a dedicated login entry for administrative access and MUST provide explicit unauthorized and session-expired states instead of leaving the user in a blank or partially rendered builder screen.

#### Scenario: Admin session expires during builder use
- **WHEN** the builder session expires while the user is using `survey-builder`
- **THEN** the application MUST interrupt further privileged actions
- **AND** it MUST show a session-expired message with a clear path back to the login entry

#### Scenario: Unauthorized screener attempts builder login
- **WHEN** a non-admin screener submits valid professional credentials in the builder login entry
- **THEN** the application MUST keep the user on the login entry with a blocked-access message that explains the account is not authorized for builder administration
- **AND** it MUST prevent navigation into survey, prompt, persona, or access-point management views

### Requirement: Survey-builder MUST provide access-point administration workflows
The `survey-builder` application MUST let authorized administrators list, create, edit, and validate agent access-point definitions alongside existing survey, prompt, and persona catalogs.

#### Scenario: Admin opens the access-point catalog
- **WHEN** an authorized admin selects agent access-point management in `survey-builder`
- **THEN** the application MUST display a dedicated access-point catalog screen
- **AND** it MUST load the existing access-point definitions from the backend

#### Scenario: Admin saves an access point
- **WHEN** the admin submits a valid access-point form with a key, display metadata, prompt selection, persona selection, and output profile
- **THEN** the application MUST persist the definition through the backend API
- **AND** it MUST show the saved configuration in the access-point catalog

### Requirement: Survey-builder MUST allow access-point model/provider configuration
The `survey-builder` access-point form MUST allow administrators to define provider/model strings for the clinical writer primary and fallback configuration.

#### Scenario: Admin edits provider/model values in access-point form
- **WHEN** an admin enters provider/model values in the access-point form and saves
- **THEN** the application MUST send those values in create/update access-point API payloads
- **AND** it MUST reload the same values when the access-point form is reopened

### Requirement: Survey-builder MUST accept free-text model names
The access-point model inputs MUST accept any non-empty string value and MUST not restrict values to a static list.

#### Scenario: Admin provides a custom model name
- **WHEN** an admin enters a non-empty custom model string
- **THEN** the application MUST allow submission
- **AND** it MUST persist the provided value without replacing it with a predefined option

### Requirement: Survey-builder MUST route privileged writes through auditable backend operations
The `survey-builder` application MUST perform privileged create, update, delete, publish, and authentication actions through backend endpoints that can emit persistent audit records. Local-only state changes MUST NOT be treated as completed administrative actions.

#### Scenario: Admin saves a survey draft
- **WHEN** a builder admin clicks save in the survey editor
- **THEN** the application MUST send the change through the backend write path
- **AND** it MUST not represent the change as completed until the backend acknowledges the auditable operation result

#### Scenario: Admin signs out from builder
- **WHEN** a builder admin performs logout from `survey-builder`
- **THEN** the application MUST use the logout flow defined for the authenticated admin session
- **AND** the operation MUST be representable in the backend audit trail

### Requirement: Survey-builder MUST provide a stable administrative home and section entry points
The `survey-builder` application MUST expose a stable home screen or dashboard from which administrators can reach survey, prompt, persona, access-point, and future administrative sections without depending on secondary actions embedded inside other screens.

#### Scenario: Admin returns to the home context from the persona catalog
- **WHEN** the admin is viewing the persona skill catalog or editor
- **THEN** the UI MUST provide an explicit action to return to the administrative home context
- **AND** the return path MUST not depend exclusively on browser navigation

#### Scenario: Builder grows with new admin sections
- **WHEN** a new administrative section such as access-point management is added
- **THEN** the application MUST expose that section from the same stable home and shell navigation model
- **AND** the new section MUST not require users to discover it through an unrelated catalog flow

### Requirement: Survey Builder MUST manage the AI agent catalog
The `survey-builder` application SHALL provide an administrative interface for listing, creating, editing, disabling, and deleting AI agent catalog records through builder-protected backend APIs.

#### Scenario: Admin lists AI agents
- **WHEN** an authorized builder admin opens the AI agent catalog screen
- **THEN** the application MUST request AI agents from the backend
- **AND** it MUST display each agent's name, provider type, default model, enabled state, and endpoint summary

#### Scenario: Admin edits an agent secret reference
- **WHEN** an authorized builder admin edits an AI agent
- **THEN** the form MUST accept an environment variable name for the API key
- **AND** it MUST NOT display or submit any raw API key value

### Requirement: Survey Builder MUST configure ordered access-point agent routes
The access-point form SHALL allow administrators to assign, reorder, enable, disable, and parameterize AI agent route entries for each access point.

#### Scenario: Admin configures local primary and remote fallback
- **WHEN** an authorized builder admin configures an access point with local Qwen first and Gemini second
- **THEN** the saved access point payload MUST include ordered `aiConfig.agentRefs`
- **AND** the UI MUST preserve the route order when the access point is reopened

#### Scenario: Admin saves invalid route
- **WHEN** an access-point route references a missing or disabled AI agent without explicitly disabling that route entry
- **THEN** the Builder UI MUST surface a validation error from the backend
- **AND** it MUST NOT silently replace the route with a different agent

### Requirement: The system MUST provide an interface for editing survey instructions.

This interface MUST allow users to edit all fields of the `instructions` object.

#### Scenario: User edits the survey instructions
-   **Given** a user is on the `SurveyFormScreen`
-   **When** they modify the text in the `preamble`, `questionText`, or `answers` fields for the instructions
-   **And** they save the survey
-   **Then** the updated instructions MUST be persisted to the database.

### Requirement: The system MUST provide an interface for managing survey questions.

This interface MUST allow users to add, edit, and remove questions and their answers. The interface SHALL use clear visual grouping and sectional wayfinding to help administrators manage large numbers of questions within a single survey form.

#### Scenario: User adds a new question to the survey
-   **Given** a user is on the `SurveyFormScreen`
-   **When** they click the "Add Question" button
-   **Then** a new, empty question widget MUST appear in the questions list.
-   **AND** the system SHOULD scroll to and highlight the new question widget.

#### Scenario: User removes a question from the survey
-   **Given** a survey has at least one question
-   **When** the user clicks the "Remove" button on a question widget
-   **Then** the corresponding question widget MUST be removed from the list.

#### Scenario: User adds an answer to a question
-   **Given** a question exists in the survey
-   **When** the user clicks the "Add Answer" button within that question's widget
-   **Then** a new, empty answer field MUST appear in that question's answer list.

#### Scenario: User removes an answer from a question
-   **Given** a question has at least one answer
-   **When** the user clicks the "Remove" button on an answer field
-   **Then** the corresponding answer field MUST be removed from that question's answer list.

#### Scenario: User navigates between questionnaire sections
- **GIVEN** a survey with many questions divided into logical groups or just a long list
- **WHEN** the user uses the sectional navigation component
- **THEN** the question list MUST scroll to the corresponding group or question index
- **AND** the question editor's sticky actions MUST remain accessible for immediate save.

### Requirement: The system MUST enforce survey validation rules.

The system MUST ensure that a survey meets minimum content requirements before it can be saved.

#### Scenario: User tries to save a survey with no questions
-   **Given** a user is editing a survey and removes all questions
-   **When** they attempt to save the survey
-   **Then** a validation error MUST be displayed, indicating that at least one question is required.
-   **And** the survey MUST NOT be saved.

#### Scenario: User tries to save a question with no answers
-   **Given** a user is editing a question and removes all of its answers
-   **When** they attempt to save the survey
-   **Then** a validation error MUST be displayed for that question, indicating that at least one answer is required.
-   **And** the survey MUST NOT be saved.

### Requirement: Sectional Navigation for Long Administrative Forms
The `survey-builder` application SHALL provide a sectional navigation component (e.g., a table of contents or sidebar) for long editing forms (Questionnaires, Prompts, Personas) to allow users to navigate between sections without exhaustive scrolling.

#### Scenario: User navigates using the sectional menu
- **WHEN** the user is editing a long survey or persona form
- **THEN** a navigation menu MUST be visible, listing all major sections of the form
- **AND** clicking a section name MUST scroll the view to that section immediately
- **AND** the menu MUST highlight the current active section as the user scrolls.

### Requirement: Persistent Save and Action Area
The `survey-builder` editing screens MUST include a persistent (sticky) action area that remains visible regardless of scroll position, containing at least the "Save" and "Cancel" actions.

#### Scenario: User scrolls a long form
- **WHEN** the user scrolls down a long questionnaire editor
- **THEN** the "Save" and "Cancel" buttons MUST remain anchored to the bottom or top of the viewport
- **AND** the "Save" button MUST remain enabled or disabled based on the form's current validation state.

### Requirement: Visual Unsaved Changes Indicator
The `survey-builder` application MUST persistently display the "Unsaved Changes" state whenever the current form has been modified but not yet successfully persisted to the backend.

#### Scenario: User modifies a field
- **WHEN** the user changes any value in an administrative form
- **THEN** a clear visual indicator (e.g., a status chip or text label) MUST appear near the save action saying "Alterações não salvas" (Unsaved changes)
- **AND** the indicator MUST update to "Salvando..." (Saving) during the write operation
- **AND** it MUST update to "Alterações salvas" (Changes saved) or disappear after a successful save.

### Requirement: Enhanced CRUD List Affordances
List views for administrative catalogs (Surveys, Prompts, Personas) MUST include clear empty states, search/filter affordances, and status indicators for items that have pending conflicts or recent updates.

#### Scenario: User views an empty catalog
- **WHEN** a catalog (e.g., Persona Skills) has no items
- **THEN** the system MUST display a descriptive empty state explaining why it's empty
- **AND** it MUST provide a clear "Create" action within the empty state container.

#### Scenario: User filters a list
- **WHEN** the user enters text in a search or filter field for a catalog
- **THEN** the list MUST update in real-time to show only matching items
- **AND** if no matches are found, a "No results" message MUST be shown with an option to clear the filter.

### Requirement: Administrative navigation MUST reduce dead ends and context loss
The `survey-builder` navigation model MUST prevent dead-end administrative screens and MUST preserve user orientation during long-lived catalog and editor workflows.

#### Scenario: Admin opens a secondary catalog
- **WHEN** an admin navigates from the survey area into a secondary catalog such as prompts or persona skills
- **THEN** the destination screen MUST show its current section clearly
- **AND** it MUST provide visible actions to return to the parent context or the administrative home

#### Scenario: Admin completes a save inside a nested editor
- **WHEN** an admin saves changes from a nested prompt, persona, or survey editor
- **THEN** the post-save state MUST preserve orientation by showing the current section and available next navigation choices
- **AND** the user MUST not land in a screen that lacks a clear onward path

### Requirement: Separation of Concerns in Authoring Forms
Administrative forms in `survey-builder` MUST separate UI rendering from business logic, validation, and data persistence.

#### Scenario: Form Page uses dedicated Controller
- **WHEN** an admin navigates to an authoring page (Survey, Access Point, AI Agent, or Persona Skill)
- **THEN** the Page widget SHALL delegate state management and repository interactions to a dedicated Controller or ViewModel.

### Requirement: Centralized Form Validation
Validation logic for administrative forms SHALL be centralized and reusable, decoupled from the UI widgets.

#### Scenario: Validation feedback in Authoring Forms
- **WHEN** an admin submits an authoring form with invalid data
- **THEN** the system SHALL provide a validation summary and highlight specific fields using centralized validation rules.

### Requirement: Local Draft Persistence
The system SHALL maintain a consistent mechanism for local draft persistence across all major authoring flows.

#### Scenario: Automatic local draft restoration
- **WHEN** an admin reopens an authoring form that was previously closed with unsaved changes
- **THEN** the system SHALL prompt for or automatically restore the local draft state.

### Requirement: Survey-builder MUST provide a shared admin navigation shell
The `survey-builder` application MUST provide a shared administrative shell that contains a stable home context, primary section navigation, and consistent page framing for all admin areas.

#### Scenario: Admin opens the authenticated builder
- **WHEN** an authorized admin enters `survey-builder`
- **THEN** the application MUST render an administrative shell with a visible home or dashboard entry
- **AND** the shell MUST provide navigation to surveys, prompts, persona skills, and future administrative sections

#### Scenario: Admin enters a catalog from the shell
- **WHEN** the admin chooses a section such as surveys or persona skills from the shell navigation
- **THEN** the application MUST load that section inside the same administrative shell
- **AND** the shell MUST preserve a visible route back to the home context

### Requirement: Questions expose optional label metadata
Every question definition in MongoDB SHALL include an optional `label` property that describes how the question should be referenced in visualizations or agent prompts. APIs that return surveys SHALL include the `label` field for each question so clients can display human-readable names instead of numeric IDs. New questions created in `survey-builder` or via API MUST accept a `label` value when provided.

#### Scenario: Persisting a labeled question
- **WHEN** a client submits a `POST /surveys` or `PUT /surveys/{id}` payload that supplies `questions[i].label`
- **THEN** the backend MUST persist that label alongside the question definition
- **AND** the survey retrieval APIs MUST return the saved label to subsequent clients

### Requirement: Legacy surveys receive fallback labels
A migration task SHALL populate `label` for existing questions by deriving a short text from the question prompt (e.g., “Luzes pulsantes”). Downstream consumers SHALL gracefully fall back to ordinal identifiers (`Q1`, `Q2`, etc.) when the label is still null.

#### Scenario: Running the label migration
- **WHEN** the migration executes after the schema change
- **THEN** it MUST inspect each stored question, derive a concise label from the question text, and persist it without requiring manual edits
- **AND** any question without a derived label MUST still render as `Q<number>` in the UI

### Requirement: Builder surfaces and edits question labels
`survey-builder` MUST let administrators provide or edit the label for every question. The label input SHALL appear in the question editor and the question list preview so administrators can confirm how the label will appear in charts or agent prompts.

#### Scenario: Editing a label inside the builder
- **WHEN** an administrator updates a question in `survey-builder` and changes the label field
- **THEN** the application MUST include the new label in the survey payload it sends to the backend
- **AND** the saved survey MUST show the updated label when reopened or previewed

#### Scenario: Previewing a question with a label
- **WHEN** the builder renders the question list or preview tiles
- **THEN** it MUST display the configured label if present
- **AND** it MUST fall back to the numeric question ID when no label exists so the UI never shows blank text
