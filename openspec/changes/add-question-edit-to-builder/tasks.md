# Tasks: Complete Survey Builder Implementation

**Status:** Executed after Dart API client generation was restored.

## Phase 1: UI/UX and Theme Fixes

-   [x] **1.1.** In `main.dart`, update the `MaterialApp` theme to use `AppTheme.light()` directly, without overriding the `colorScheme`, to fix the top bar color.
-   [x] **1.2.** In `SurveyFormScreen`, add an asterisk (`*`) to the `labelText` of all required `TextFormField` widgets.
-   [x] **1.3.** Add a "Cancel" button (`TextButton` or `OutlinedButton`) to the `SurveyFormScreen`.
-   [x] **1.4.** Implement a confirmation dialog when the "Cancel" button is pressed if there are unsaved changes.

## Phase 2: Instructions and Questions Editor

-   [x] **2.1.** In `SurveyFormScreen`, add `TextFormField` widgets for the `instructions` fields (`preamble`, `questionText`, `answers`).
-   [x] **2.2.** Implement the UI for displaying the list of questions in `SurveyFormScreen` using a `ListView.builder`.
-   [x] **2.3.** Implement the UI for displaying answers for each question using a nested `ListView.builder`.
-   [x] **2.4.** Add an "Add Question" button to the `SurveyFormScreen`.
-   [x] **2.5.** Add an "Add Answer" button to each question widget.
-   [x] **2.6.** Implement the "Remove" functionality for both questions and answers.

## Phase 3: Validation and Integration

-   [x] **3.1.** In `SurveyFormScreen`, update the form submission logic to include the `instructions` and `questions` data.
-   [x] **3.2.** Add form validation to ensure that a survey has at least one question before saving.
-   [x] **3.3.** Add form validation to ensure that each question has at least one answer before saving.
-   [x] **3.4.** Update the widget tests in `test/widget_test.dart` to cover the new UI elements, logic, and validations.
