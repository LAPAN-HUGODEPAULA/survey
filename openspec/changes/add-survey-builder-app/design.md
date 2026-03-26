# Design: Survey Builder Application

## 1. Architectural Approach

The user requested that the `survey-builder` application directly access the MongoDB database. However, the established architecture of the LAPAN Survey Platform dictates that frontend applications do not interact directly with the data layer. Instead, they communicate with backend services via a well-defined API contract (OpenAPI).

**Decision:** We will adhere to the existing architectural pattern. The `survey-builder` app will not connect directly to MongoDB. Instead, we will introduce a new set of RESTful endpoints in the `survey-backend` (FastAPI) service.

**Rationale:**

*   **Security:** Direct database access from a client-side application is a significant security vulnerability. It would require embedding database credentials in the application, which can be easily extracted. All access control and validation logic would have to be duplicated in the app, which is not secure.
*   **Separation of Concerns:** The current architecture correctly separates the frontend (presentation) from the backend (business logic and data access). A direct database connection would violate this principle, leading to a more complex and less maintainable system.
*   **Consistency:** All other applications in the ecosystem use the backend API. Introducing a different pattern for this one app would create inconsistency and increase the cognitive load for developers.
*   **Scalability & Maintainability:** A central API allows for better control over database interactions, caching, and future data model changes. If the schema evolves, we only need to update the backend service, not every client application.

## 2. Technical Design

1.  **Backend API (`survey-backend`):**
    *   A new FastAPI router (`/surveys`) will be created.
    *   This router will provide standard CRUD endpoints:
        *   `GET /surveys`: List all surveys (with pagination).
        *   `POST /surveys`: Create a new survey.
        *   `GET /surveys/{survey_id}`: Retrieve a single survey by its ID.
        *   `PUT /surveys/{survey_id}`: Update an existing survey.
        *   `DELETE /surveys/{survey_id}`: Delete a survey.
    *   Survey payloads will expose a single nullable `prompt` reference instead of `promptAssociations`.
    *   The prompt reference will contain only the minimal reusable metadata required by clients:
        *   `promptKey`
        *   `name`
    *   Prompt definitions in the reusable prompt catalog will keep:
        *   `promptKey`
        *   `name`
        *   `promptText`
    *   Prompt definitions and survey references will no longer carry `outcomeType`.
    *   These endpoints will use the existing repository pattern for database interactions, ensuring business logic and data access are properly handled.
    *   The OpenAPI specification at `packages/contracts/survey-backend.openapi.yaml` will be updated to reflect these new endpoints.

2.  **Frontend Application (`survey-builder`):**
    *   A new Flutter application will be created under `apps/survey-builder`.
    *   It will be configured similarly to the other Flutter apps (`survey-frontend`, `survey-patient`).
    *   It will utilize the shared `packages/design_system_flutter` for a consistent look and feel.
    *   After the backend API is updated, the Dart client will be regenerated using the `./tools/scripts/generate_clients.sh` script.
    *   The app will use the generated Dart client to interact with the new `/surveys` endpoints.
    *   The survey editor will expose a single optional prompt selector for the questionnaire.
    *   The prompt management UI will create and edit reusable prompts without any prompt-type field.

### 2.1. Questionnaire Prompt Model

**Decision:** Each survey will store a single nullable prompt reference.

Example shape:

```json
{
  "_id": "survey-123",
  "surveyDisplayName": "Autism Intake",
  "prompt": {
    "promptKey": "autism-intake-summary",
    "name": "Autism Intake Summary"
  }
}
```

The `prompt` field may be `null` when a survey does not yet have an AI prompt configured.

**Why:**

*   **Product fit:** The questionnaire flow now needs one prompt per survey, not a menu of prompt outcomes.
*   **Contract clarity:** A single nullable field is easier to validate and reason about than a list with custom uniqueness rules.
*   **UI simplicity:** The builder can present one optional selector instead of a grid of per-outcome controls.
*   **Runtime determinism:** Report-generation flows can automatically use the configured prompt without relying on list order or user choice.

### 2.2. Reusable Prompt Catalog

**Decision:** Reusable survey prompts will remain cataloged centrally, but they will no longer be classified by prompt type.

**Why:**

*   Prompt types were previously used to support multiple questionnaire outcomes, which is no longer part of the product model.
*   Keeping only `promptKey`, `name`, and `promptText` preserves reuse without forcing an artificial taxonomy into the UI and API.

### 2.3. Legacy Data Handling

Legacy surveys may already contain `promptAssociations`. The migration strategy MUST avoid silent data loss.

**Decision:** Existing survey documents must be normalized into the new `prompt` field during migration.

**Why:**

*   Silent collapse of multiple legacy prompt associations into a single prompt would hide business decisions and make regressions hard to detect.
*   The migration must make the new contract explicit so the builder and report flows operate on one canonical field.

Migration rules:

*   If a survey has no existing prompt associations, store `prompt: null`.
*   If a survey has exactly one existing prompt association, copy its `promptKey` and `name` into `prompt`.
*   If a survey has more than one existing prompt association, the migration must flag that survey for manual resolution instead of discarding prompt data implicitly.

## 3. User Experience Flow


The user will experience a simple, form-based interface:

*   **Main Screen:** A list of existing surveys with options to "Create New" or "Edit/Delete" existing ones.
*   **Editor Screen:** A form that allows creating or editing the survey structure, fields, and properties. The fields will map to the survey API contract, including a single optional reusable prompt reference.

### 3.1. Detailed Editor Screen Design

The editor screen will be enhanced with the following features to provide a richer user experience:

#### 3.1.1. Rich Text Editing

To allow for more expressive content, the following text fields will be replaced with a WYSIWYG HTML editor powered by the `quill_html_editor` package:

*   **Survey Description:** A rich text editor for the survey's description.
*   **Preamble:** A rich text editor for the survey's preamble.
*   **Final Notes:** A rich text editor for the survey's final notes.

This will provide administrators with the flexibility to format text, add links, and embed media, improving the overall presentation of the survey.

#### 3.1.2. Question Management

To facilitate the organization of survey questions, the following features will be implemented:

*   **Question Reordering:** Each question in the survey editor will have "Up" and "Down" arrow buttons. Clicking these buttons will move the question one position up or down in the list, respectively. The UI will update immediately to reflect the new order.

#### 3.1.3. Data Management

To enable data portability and backup, the following functionality will be added:

*   **Export Surveys:** A button labeled "Export Surveys" will be added to the main screen. When clicked, this button will trigger a download of all surveys from the database as a single JSON file. A new backend endpoint will be created to support this functionality.

#### 3.1.4. Prompt Configuration

The editor will allow the user to attach zero or one reusable prompt to the questionnaire.

**Why:**

*   A questionnaire may be saved before its AI prompt is defined, so the field must be nullable.
*   A questionnaire no longer supports multiple prompt outcomes, so the editor must not present per-type prompt controls.

The UI behavior will be:

*   The survey form shows one optional prompt selector populated from the reusable prompt catalog.
*   The user may leave the selector empty, which persists `prompt: null`.
*   When a prompt is selected, the saved survey stores that single prompt reference.
*   When editing an existing survey, the selector must preload the stored prompt when present.

### 3.2. UI Design for Editing Instructions and Questions

#### 3.2.1. Instructions Editor

A dedicated section will be added to the `SurveyFormScreen` to edit the `instructions`. Since `instructions` is a complex object (`preamble`, `questionText`, `answers`), we will use separate `TextFormField` widgets for each of its fields.

#### 3.2.2. Questions Editor

The `questions` field is a list of complex objects, each with a list of answers. This requires a dynamic UI to manage the list of questions and their answers.

*   **Questions List:** A `ListView.builder` will be used to display the list of questions. Each item will have a "Remove" button to delete the question.
*   **Question Widget:** Each question will be represented by a `Card` containing:
    *   A `TextFormField` for the question's text.
    *   A `ListView.builder` for the question's answers. Each answer will have a `TextFormField` for its text and a "Remove" button.
    *   An "Add Answer" button within each question's card.
*   **Add Question Button:** A main "Add Question" button will be present at the bottom of the questions list to add new questions to the survey.

This nested structure will be managed using a `StatefulWidget` and local state management (`setState`) to handle the dynamic addition and removal of questions and answers.

#### 3.2.3. Prompt Management Editor

The prompt management screen will support reusable prompt CRUD with the following fields:

*   `name`
*   `promptKey`
*   `promptText`

It will not expose any prompt-type or outcome-type selector.

**Why:**

*   Prompt classification no longer drives questionnaire behavior.
*   Removing unused taxonomy makes the catalog easier to maintain and reduces validation burden.

### 3.3. Theme Fix

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

### 3.4. UI/UX Improvements

#### 3.4.1. Required Field Indicator

To indicate required fields, an asterisk (`*`) will be added to the label of each required `TextFormField`. This is a standard usability practice.

```dart
// Example in SurveyFormScreen
TextFormField(
  decoration: InputDecoration(labelText: 'Nome de Exibição da Pesquisa *'),
  // ...
),
```

#### 3.4.2. "Cancel" Button Usability Research

**Question:** Is a "Cancel" button necessary on the edit page, even though the back button provides the same functionality?

**Research and Analysis:**

*   **Nielsen Norman Group Guidelines:** Usability experts from NN/g recommend providing explicit "Cancel" buttons, especially in forms. While the back button can achieve the same result, an explicit "Cancel" button makes the action clearer and more discoverable for users. It reduces ambiguity about what the back button does (does it save, or discard?).
*   **Platform Conventions:**
    *   **Web:** Explicit "Cancel" or "Discard" buttons are very common.
    -   **Mobile:** The back button is a more common and understood pattern for dismissing a screen without saving. However, for forms with significant data entry, an explicit "Cancel" button can prevent accidental data loss and provide clearer user intent.
*   **Context of this app:** The `survey_builder` is a data entry-intensive application. Users might invest significant time creating or editing a survey.

**Recommendation:**

**Yes, we should add a "Cancel" button.**

An explicit "Cancel" button will improve usability by:
1.  **Providing a clear, unambiguous action** to discard changes.
2.  **Reducing the risk of accidental data loss** by prompting the user for confirmation if they have unsaved changes.

The "Cancel" button will be implemented as a secondary button (e.g., `TextButton` or `OutlinedButton`) next to the primary "Save" button. When pressed, it will check if there are unsaved changes. If so, it will show a confirmation dialog ("Are you sure you want to discard your changes?").

This design ensures the new application is secure, maintainable, and consistent with the rest of the LAPAN Survey Platform.
