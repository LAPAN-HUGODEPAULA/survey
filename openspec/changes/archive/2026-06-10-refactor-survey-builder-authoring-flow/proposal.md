## Why

The current implementation of survey authoring forms in `survey-builder` is monolithic and violates the separation of concerns principle. Pages like `SurveyFormPage` exceed 1000 lines, mixing repository initialization, state management, complex validation logic, local draft persistence, and UI rendering, which makes maintenance difficult and increases the risk of regressions.

## What Changes

- **Componentization**: Split monolithic form pages into smaller, focused widgets (e.g., `SurveyDetailsSection`, `QuestionsList`).
- **State Management**: Extract form state and business logic from the `State` classes into dedicated controllers or ViewModels.
- **Validation**: Centralize and externalize validation logic into standalone validator classes or functions.
- **Mapping & Serialization**: Move draft-to-domain mapping and serialization logic into dedicated mapper classes.
- **Cleanup**: Remove dead variables, unused imports, and redundant functions discovered during the refactoring.

## Capabilities

### New Capabilities
- `authoring-flow-standardization`: Defines the architectural standard for all administrative forms in the `survey-builder` ecosystem, ensuring consistency in how state, validation, and persistence are handled.

### Modified Capabilities
<!-- No functional requirements are changing; behavior is preserved while the underlying architecture is improved. -->

## Impact

- **Affected Code**: `SurveyFormPage`, `AgentAccessPointFormPage`, `AIAgentFormPage`, and `PersonaSkillFormPage` in `apps/survey-builder`.
- **Developer Experience**: Improved code readability, easier unit testing of business logic, and reduced cognitive load during maintenance.
- **Risk**: Low risk of breaking existing behavior if properly verified through automated and manual smoke tests.
