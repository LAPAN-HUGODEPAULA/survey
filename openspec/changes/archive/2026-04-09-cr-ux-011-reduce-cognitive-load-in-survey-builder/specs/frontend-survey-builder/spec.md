## MODIFIED Requirements

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
