# ui-ux-theme-fixes Specification

## Purpose
TBD - created by archiving change add-question-edit-to-builder. Update Purpose after archive.

## Requirements
### Requirement: The application theme MUST be consistent with the LAPAN Survey Platform.
The application's color scheme, particularly the top app bar, MUST match the established theme of other applications.

#### Scenario: User opens the application
**Given** the `survey_builder` application is launched
**When** the `SurveyListScreen` is displayed
**Then** the top app bar color MUST be orange, consistent with the `design_system_flutter`'s primary color.

### Requirement: Required form fields MUST be clearly indicated.
To improve usability and reduce user error, all mandatory fields in a form MUST be visually distinguished.

#### Scenario: User views the survey creation/editing form
**Given** a user is on the `SurveyFormScreen`
**When** the form is displayed
**Then** the label for each required field (e.g., "Nome de Exibição da Pesquisa") MUST include an asterisk (`*`).

### Requirement: The application MUST provide a clear way to cancel form edits.
To prevent accidental data loss and provide a clear user flow, there MUST be an explicit action to discard changes in a form.

#### Scenario: User discards changes in the survey form
**Given** a user has made changes to the survey form
**When** they click the "Cancel" button
**Then** a confirmation dialog MUST be displayed, asking if they are sure they want to discard the changes.
**When** the user confirms the action
**Then** the `SurveyFormScreen` MUST be closed, and no changes MUST be saved.

#### Scenario: User cancels without making changes
**Given** a user has not made any changes to the survey form
**When** they click the "Cancel" button
**Then** the `SurveyFormScreen` MUST be closed immediately, without a confirmation dialog.
