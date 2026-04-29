## MODIFIED Requirements

### Requirement: Survey respondent applications MUST reuse shared respondent-flow components
The applications `survey-frontend` and `survey-patient` SHALL consume shared respondent-flow components for the duplicated survey experience, including async page state, demographic data capture, instruction comprehension, linear question presentation, and survey metadata presentation.

#### Scenario: A survey app renders a duplicated respondent-flow screen
- **WHEN** `survey-frontend` or `survey-patient` renders a demographics, instructions, survey runner, or survey details screen
- **THEN** the screen MUST be composed from shared components exported by `packages/design_system_flutter`
- **AND** the application MAY keep a thin local page wrapper for navigation, repository access, and provider integration

#### Scenario: Option buttons render with consistent gradient styling
- **WHEN** a survey app renders option buttons via `SurveyOptionButton`
- **THEN** the buttons MUST display a top-left-to-bottom-right gradient using the assigned palette color
- **AND** the gradient MUST be identical across `survey-patient`, `survey-frontend`, and `survey-builder`

#### Scenario: Question runner uses endowment-effect progress
- **WHEN** `DsSurveyQuestionRunner` is rendered in any consuming app
- **THEN** the progress indicator MUST use `includeSuccessPage: true`
- **AND** the progress MUST NOT reach 100% until the user transitions past the last question

#### Scenario: Back button text is visible on dark background
- **WHEN** the "Voltar para a pergunta anterior" button is displayed in `DsSurveyQuestionRunner`
- **THEN** the text color MUST be white to match the option button text styling
