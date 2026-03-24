# Design: Completing the Survey Builder

This document outlines the design for the completion of the `survey_builder` application, focusing on question and instruction editing, UI/UX improvements, and theme corrections.

## 1. UI Design for Editing Instructions and Questions

### 1.1. Instructions Editor

A dedicated section will be added to the `SurveyFormScreen` to edit the `instructions`. Since `instructions` is a complex object (`preamble`, `questionText`, `answers`), we will use separate `TextFormField` widgets for each of its fields.

### 1.2. Questions Editor

The `questions` field is a list of complex objects, each with a list of answers. This requires a dynamic UI to manage the list of questions and their answers.

-   **Questions List:** A `ListView.builder` will be used to display the list of questions. Each item will have a "Remove" button to delete the question.
-   **Question Widget:** Each question will be represented by a `Card` containing:
    -   A `TextFormField` for the question's text.
    -   A `ListView.builder` for the question's answers. Each answer will have a `TextFormField` for its text and a "Remove" button.
    -   An "Add Answer" button within each question's card.
-   **Add Question Button:** A main "Add Question" button will be present at the bottom of the questions list to add new questions to the survey.

This nested structure will be managed using a `StatefulWidget` and local state management (`setState`) to handle the dynamic addition and removal of questions and answers.

## 2. Theme Fix

The issue with the top bar color not matching other apps stems from how the theme is being applied. While `AppTheme.light()` from `design_system_flutter` is used, the `colorScheme` is being overridden with `ColorScheme.fromSeed(seedColor: Colors.orange)`.

**Decision:** We will use the `AppTheme.light()` directly without overriding the `colorScheme`, as `AppTheme.light()` already defines the correct color scheme for the application.

```dart
// In main.dart
MaterialApp(
  title: 'Survey Builder',
  theme: AppTheme.light(), // Use the theme directly
  home: const SurveyListScreen(),
);
```

## 3. UI/UX Improvements

### 3.1. Required Field Indicator

To indicate required fields, an asterisk (`*`) will be added to the label of each required `TextFormField`. This is a standard usability practice.

```dart
// Example in SurveyFormScreen
TextFormField(
  decoration: InputDecoration(labelText: 'Nome de Exibição da Pesquisa *'),
  // ...
),
```

### 3.2. "Cancel" Button Usability Research

**Question:** Is a "Cancel" button necessary on the edit page, even though the back button provides the same functionality?

**Research and Analysis:**

-   **Nielsen Norman Group Guidelines:** Usability experts from NN/g recommend providing explicit "Cancel" buttons, especially in forms. While the back button can achieve the same result, an explicit "Cancel" button makes the action clearer and more discoverable for users. It reduces ambiguity about what the back button does (does it save, or discard?).
-   **Platform Conventions:**
    -   **Web:** Explicit "Cancel" or "Discard" buttons are very common.
    -   **Mobile:** The back button is a more common and understood pattern for dismissing a screen without saving. However, for forms with significant data entry, an explicit "Cancel" button can prevent accidental data loss and provide clearer user intent.
-   **Context of this app:** The `survey_builder` is a data entry-intensive application. Users might invest significant time creating or editing a survey.

**Recommendation:**

**Yes, we should add a "Cancel" button.**

An explicit "Cancel" button will improve usability by:
1.  **Providing a clear, unambiguous action** to discard changes.
2.  **Reducing the risk of accidental data loss** by prompting the user for confirmation if they have unsaved changes.

The "Cancel" button will be implemented as a secondary button (e.g., `TextButton` or `OutlinedButton`) next to the primary "Save" button. When pressed, it will check if there are unsaved changes. If so, it will show a confirmation dialog ("Are you sure you want to discard your changes?").
