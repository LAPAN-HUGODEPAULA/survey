# Proposal: Complete Survey Builder Implementation with Question Editing

This proposal outlines the necessary changes to complete the implementation of the `survey_builder` application. The current implementation only allows editing of basic survey fields. This proposal will add the functionality to edit the `instructions` and `questions` fields, making it possible to create and edit full surveys.

This change will also address UI/UX inconsistencies and theme issues to ensure the application is user-friendly and visually aligned with the other LAPAN Survey Platform applications.

## Key Features

1.  **Full Survey Editing:**
    *   Implement UI for editing the `instructions` object of a survey.
    *   Implement UI for adding, removing, and editing questions and their respective answers within a survey.

2.  **Validation:**
    *   Enforce that a survey must contain at least one question upon saving.
    *   Enforce that each question must have at least one answer.

3.  **UI/UX and Theme Improvements:**
    *   Fix the top bar color to match the theme of other applications in the platform.
    *   Add an asterisk (`*`) to the labels of all required fields to improve usability.
    *   Provide a recommendation on the necessity of a "Cancel" button on the edit page, based on usability guidelines.
