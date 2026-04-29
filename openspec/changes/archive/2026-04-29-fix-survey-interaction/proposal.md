## Why

Recent UI changes introduced visual and UX inconsistencies across survey-patient, survey-frontend, and survey-builder. The option buttons lost their gradient treatment while other buttons retain it, creating a split design language. Additionally, the progress bar reaches 100% prematurely, the report page is a navigation dead-end, key text lacks visibility, and the thank-you page carries unnecessary clutter. These issues collectively degrade user experience and trust in the interface.

## What Changes

- **Standardize option button gradients** across all three apps using natural-lighting gradients (lighter top-left, darker bottom-right) via `SurveyOptionButton` and `SurveyOptionColors`
- **Fix progress bar math** in `DsSurveyProgressIndicator` to treat the success/thank-you page as the final milestone: first question starts at ~5%, last question caps at ~90-95%, success page reaches 100%
- **Add navigation to report page** (`report_page.dart`) — a back button returning to `thank_you_page.dart` and a "Iniciar nova avaliação" button matching the one on `thank_you_page.dart`
- **Improve "Voltar para a pergunta anterior" text visibility** in `DsSurveyQuestionRunner` — switch to white foreground color matching the option buttons
- **Remove "Resumo das respostas" section** entirely from `thank_you_page.dart` (the radar chart section stays; only the text summary list is removed)
- **Add "Gerar relatório" button** to the `DsHandoffFork` on `thank_you_page.dart`, placed alongside the existing "Adicionar informações" action

## Capabilities

### New Capabilities

- `survey-option-gradient`: Unified gradient treatment for survey option buttons across all apps using natural-lighting directional gradients
- `survey-progress-endowment`: Endowment-effect hybrid progress bar that reserves 100% for post-submission success state
- `report-page-navigation`: Back navigation and restart-survey actions on the report page to eliminate dead-ends
- `thank-you-page-actions`: Restructured handoff actions on the thank-you page with report generation capability

### Modified Capabilities

- `patient-survey-flow`: Progress indicator behavior changes affect the survey completion flow contract
- `shared-flutter-component-library`: `SurveyOptionButton` and `DsSurveyProgressIndicator` widget API changes

## Impact

- **packages/design_system_flutter**: `survey_option_button.dart`, `survey_progress_indicator.dart`, `app_theme.dart`, `color_palette.dart`
- **apps/survey-patient**: `thank_you_page.dart`, `report_page.dart`
- **apps/survey-frontend**: Any screens using `DsSurveyQuestionRunner` or `SurveyOptionButton`
- **apps/survey-builder**: Any screens using `DsSurveyQuestionRunner` or `SurveyOptionButton`
- No backend or API changes required
