# Spec: Frontend Survey Builder

This spec defines the user-facing application for managing surveys.

## ADDED Requirements

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

### Requirement: The system MUST provide a user interface for managing reusable survey prompts.

The system MUST provide a user interface for managing reusable survey prompts.

Reusable prompts remain cataloged in `survey-builder`, but the catalog no longer includes prompt types because questionnaires now reference at most one prompt.

This is required to keep prompt administration reusable without forcing the user to maintain metadata that no longer changes questionnaire behavior.

#### Scenario: User creates a reusable prompt
- **Given** the user is managing reusable survey prompts in `survey-builder`
- **When** they submit a prompt name, `promptKey`, and prompt text
- **Then** the application MUST create the prompt through the backend API
- **And** it MUST show the saved prompt in the prompt catalog

#### Scenario: User edits a reusable prompt
- **Given** a reusable prompt already exists
- **When** the user changes its metadata or prompt text and saves
- **Then** the application MUST update the prompt through the backend API
- **And** it MUST show the updated prompt details in the prompt catalog

#### Scenario: Prompt forms do not expose prompt types
- **Given** the user is creating or editing a reusable prompt
- **When** the prompt form is shown
- **Then** the application MUST NOT display any `outcomeType` or prompt-type selector

### Requirement: The system MUST allow users to configure a single nullable prompt reference while editing a survey.

The survey form MUST allow the user to choose zero or one reusable prompt for the questionnaire. The field is nullable because not every survey needs AI generation at creation time, and it is singular because the questionnaire no longer supports multiple prompt outcomes.

#### Scenario: User selects one prompt for a survey
- **Given** the user is editing a survey in `survey-builder`
- **And** reusable prompts exist in the prompt catalog
- **When** the user selects a prompt and saves the survey
- **Then** the application MUST include that single `prompt` reference in the survey create or update request
- **And** it MUST preserve that prompt when the survey is reopened for editing

#### Scenario: User leaves the survey without a prompt
- **Given** the user is creating or editing a survey
- **When** they leave the prompt selector empty and save
- **Then** the application MUST persist `prompt` as `null`

#### Scenario: User clears an existing prompt
- **Given** the survey already has a configured prompt
- **When** the user clears the prompt selection and saves
- **Then** the application MUST update the survey so its `prompt` becomes `null`
