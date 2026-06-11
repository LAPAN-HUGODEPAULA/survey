## Context

The `survey-builder` application contains several complex forms for authoring clinical questionnaires, AI agents, and personas. These forms have evolved into monolithic `StatefulWidget` implementations where the `State` class handles everything from database logic to UI rendering. This design makes the code fragile, hard to test, and difficult to maintain as requirements evolve.

## Goals / Non-Goals

**Goals:**
- Implement a consistent Controller pattern (using `ChangeNotifier`) to decouple business logic from the UI.
- Extract large sections of the UI into smaller, reusable stateless or stateful widgets.
- Externalize validation logic to dedicated classes or utility functions.
- Simplify the `Page` widgets to focus on layout and high-level orchestration.
- Preserve all existing features, including local draft persistence and validation feedback.

**Non-Goals:**
- Redesigning the visual appearance of the forms.
- Changing the underlying data models or API contracts.
- Introducing a complex state management library (e.g., Bloc, Riverpod) unless already established (sticking to `ChangeNotifier` for consistency with `BuilderAuthController`).

## Decisions

- **Controller Pattern (`ChangeNotifier`)**: Each major form will have a dedicated `Controller` (e.g., `SurveyFormController`). The controller will hold the form state, handle repository calls, and manage local draft persistence via `SharedPreferences`.
- **Feature-Based Componentization**: Form sections (like "Questions" in `SurveyFormPage`) will be extracted into separate widgets. This reduces the size of the main build method and makes it easier to navigate the code.
- **Validator Strategy**: Static validation methods will be grouped by domain (e.g., `SurveyValidators`) to keep the UI code clean and allow for easier unit testing of validation rules.
- **Mapper Classes**: Logic for converting between UI-specific state and the `Draft` models will be isolated, preventing the "copy-paste" style of serialization currently found in the `State` classes.

## Risks / Trade-offs

- **Risk**: Refactoring such large files could introduce subtle bugs in state management (e.g., a field not being marked dirty).
  - **Mitigation**: Perform rigorous manual testing of all fields and persistence cycles. Use `flutter analyze` and existing tests to catch regressions.
- **Trade-off**: Adding more files (Controllers, Validators, Sub-widgets) increases the number of files in the project.
  - **Rationale**: This is a worthwhile trade-off for significantly improved maintainability and readability of the core authoring logic.

## Migration Plan

1.  **Extract Validation**: Move all `DsFormValidators` and custom validation logic out of the `State` classes.
2.  **Create Controllers**: Implement `ChangeNotifier` controllers for each form, starting with the smaller ones (`PersonaSkill`, `AIAgent`) and then tackling the monolithic `SurveyFormPage`.
3.  **Refactor UI**: Gradually move blocks of UI into sub-widgets, passing the controller as a dependency.
4.  **Verify Persistence**: Ensure `SharedPreferences` logic still works correctly within the new controller structure.
