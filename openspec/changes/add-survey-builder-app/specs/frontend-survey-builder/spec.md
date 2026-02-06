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
