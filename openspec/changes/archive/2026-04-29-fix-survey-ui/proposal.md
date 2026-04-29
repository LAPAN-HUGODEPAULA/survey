## Why

Patients reported low readability and usability issues in the survey experience, including low-contrast text and buttons, non-scrollable content on low-resolution devices, and an unreadable radar summary. These issues directly affect accessibility and completion reliability in core respondent flows and must be corrected in the shared design system and both survey apps.

## What Changes

- Remove the welcome subtitle text `"Olá! Estamos com você em cada etapa."` from the patient welcome screen.
- Increase contrast for status/metadata orange text (e.g., `"Progresso (2 de 5)"`, `"Questionário ativo"`) against card backgrounds to meet a minimum contrast ratio of 6:1.
- Increase contrast for the four answer button fills used by `DsSurveyQuestionData` so white button text meets a minimum contrast ratio of 6:1.
- Add vertical scrolling behavior for long content sections rendered through shared section containers (`DsSection`) so low-resolution devices can access full content.
- Normalize thank-you radar scoring to a `0..3` range with deterministic option mapping:
  - `Quase nunca = 0`
  - `Ocasionalmente = 1`
  - `Frequentemente = 2`
  - `Quase sempre = 3`
- Improve radar label readability with stronger contrast treatment (including darker label backgrounds with light text) and apply consistently to `survey-patient` and `survey-frontend`.

## Capabilities

### New Capabilities
- _None._

### Modified Capabilities
- `patient-survey-flow`: Adjust patient welcome-screen copy and ensure respondent-flow content remains accessible on small screens.
- `shared-flutter-component-library`: Strengthen shared theme/component contrast rules (status text, survey answer buttons, and shared section scroll behavior).
- `multi-step-progress-standard`: Require stronger contrast for textual progress indicators when rendered on tonal surfaces.
- `patient-assessment-summary`: Standardize thank-you radar score mapping and readable radar label rendering across survey apps.

## Impact

- Affected code:
  - `apps/survey-patient` (`welcome_page.dart`, `survey_page.dart`, `thank_you_page.dart` integrations)
  - `apps/survey-frontend` (`thank_you_page.dart` integration)
  - `packages/design_system_flutter` (theme tokens, survey widgets, section containers, radar widget)
- No backend API contract changes expected.
- UI regression risk in shared components; requires targeted visual validation in both respondent apps and low-resolution viewport checks.
