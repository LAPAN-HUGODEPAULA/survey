## 1. Preparation and Shared Logic

- [x] 1.1 Create `lib/features/survey/validators/` directory and extract shared validation logic.
- [x] 1.2 Implement a base FormController class if common patterns (like local draft saving) can be abstracted.

## 2. Refactor Persona Skill Authoring Flow

- [x] 2.1 Create `PersonaSkillFormController` and move state/repository logic from `PersonaSkillFormPage`.
- [x] 2.2 Extract `PersonaSkillDetailsSection` and `PersonaSkillInstructionsSection` widgets.
- [x] 2.3 Update `PersonaSkillFormPage` to use the new controller and components.
- [x] 2.4 Verify creation and editing of persona skills.

## 3. Refactor AI Agent Authoring Flow

- [x] 3.1 Create `AIAgentFormController` and move state/repository logic from `AIAgentFormPage`.
- [x] 3.2 Extract `AIAgentDetailsSection` and `AIAgentCapabilitiesSection` widgets.
- [x] 3.3 Update `AIAgentFormPage` to use the new controller and components.
- [x] 3.4 Verify creation and editing of AI agents.

## 4. Refactor Agent Access Point Authoring Flow

- [x] 4.1 Create `AgentAccessPointFormController` and move state/repository/catalog logic from `AgentAccessPointFormPage`.
- [x] 4.2 Extract major UI sections (Routing, AI Config, Orchestrator Overrides) into separate widgets.
- [x] 4.3 Update `AgentAccessPointFormPage` to use the new controller and components.
- [x] 4.4 Verify all injection point behaviors and AI route configurations.

## 5. Refactor Survey Authoring Flow (The Monolith)

- [x] 5.1 Create `SurveyFormController` and implement the complex state management (questions, answers, nested lists).
- [x] 5.2 Move `SharedPreferences` local draft persistence into `SurveyFormController`.
- [x] 5.3 Extract UI sections: `SurveyDetailsSection`, `SurveyInstructionsSection`, `SurveyAiConfigSection`, `SurveyQuestionsSection`.
- [x] 5.4 Update `SurveyFormPage` to use the new controller and sub-widgets.
- [x] 5.5 Perform comprehensive manual testing of the entire survey authoring lifecycle.

## 6. Cleanup and Final Validation

- [x] 6.1 Audit all refactored files for unused imports or dead variables.
- [x] 6.2 Run `flutter analyze` across `survey-builder` to ensure no warnings or errors remain.
- [x] 6.3 Run existing unit/widget tests for the authoring features.
