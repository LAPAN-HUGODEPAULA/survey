## 1. Option Button Gradient

- [x] 1.1 Update `SurveyOptionButton` in `packages/design_system_flutter/lib/widgets/survey_option_button.dart` to apply a `LinearGradient` (top-left to bottom-right) using the palette color darkened ~12% at the bottom-right
- [x] 1.2 Verify gradient renders consistently in `survey-patient`, `survey-frontend`, and `survey-builder` by checking all screens that use `DsSurveyQuestionRunner` or `SurveyOptionButton`

## 2. Progress Bar Endowment Effect

- [x] 2.1 Add optional `includeSuccessPage` parameter (default `false`) to `DsSurveyProgressIndicator` in `packages/design_system_flutter/lib/widgets/survey_progress_indicator.dart`
- [x] 2.2 Implement endowment formula: when `includeSuccessPage` is `true`, denominator = `total + 1`, progress = `max(0.02, (currentIndex + 1) / (total + 1))`
- [x] 2.3 Update `DsSurveyQuestionRunner` to pass `includeSuccessPage: true` to `DsSurveyProgressIndicator`

## 3. Question Runner Back Button Visibility

- [x] 3.1 In `packages/design_system_flutter/lib/components/respondent_flow/ds_survey_question_runner.dart`, add `foregroundColor: Colors.white` to the `TextButton.styleFrom` for the "Voltar para a pergunta anterior" button

## 4. Thank-You Page Cleanup and Actions

- [x] 4.1 Remove the "Resumo das respostas" text section (the `DsFocusFrame` loop with individual answer cards) from `apps/survey-patient/lib/features/survey/pages/thank_you_page.dart`, keeping the radar chart and legend chips
- [x] 4.2 Add a second `DsHandoffForkAction` titled "Gerar relatório" to the `DsHandoffFork` actions list, with navigation to the report page via `AppNavigator.toReport`
- [x] 4.3 Verify that "Adicionar informações" and "Gerar relatório" render side-by-side in the fork UI

## 5. Report Page Navigation

- [x] 5.1 Add `onRestartSurvey` callback parameter to `ReportPage` in `apps/survey-patient/lib/features/report/pages/report_page.dart`
- [x] 5.2 Change `DsScaffold.backLabel` from "Voltar para os dados demográficos" to "Voltar" and ensure `onBack` pops to the thank-you page
- [x] 5.3 Add a full-width `DsOutlinedButton` labeled "Iniciar nova avaliação" at the bottom of the report page body, calling `onRestartSurvey`
- [x] 5.4 Wire `onRestartSurvey` in the parent route that navigates to `ReportPage`, using the same `restartAssessmentFlow` + `replaceWithEntryGate` pattern from the thank-you page

## 6. Verification

- [x] 6.1 Run Flutter tests in `packages/design_system_flutter` to verify no regressions in `SurveyOptionButton` and `DsSurveyProgressIndicator`
- [x] 6.2 Run Flutter tests in `apps/survey-patient` to verify thank-you page and report page changes
- [ ] 6.3 Manual smoke test: complete a full survey flow in survey-patient, verify progress bar never hits 100% on last question, verify all navigation paths work, verify gradient styling on option buttons
