## Context

The three Flutter survey apps (survey-patient, survey-frontend, survey-builder) share the design system in `packages/design_system_flutter`. Recent commits changed option button colors in `DsSurveyQuestionData` to flat colors via `SurveyOptionColors.palette`, while other buttons in the apps still use gradient fills. This created a visual inconsistency. The `DsSurveyProgressIndicator` uses `(currentIndex + 1) / total` which hits 100% on the last question, and the "Voltar para a pergunta anterior" `TextButton` uses default theme text color which is nearly invisible on the dark background.

The report page in survey-patient uses `Navigator.of(context).pop()` via `DsScaffold.onBack` but navigates to demographics, making it effectively a dead-end from the patient's perspective since there's no way back to the thank-you page or to restart.

The thank-you page has a "Resumo das respostas" text list below the radar chart, and the `DsHandoffFork` only offers "Adicionar informações" without a direct path to generate the report.

## Goals / Non-Goals

**Goals:**
- Unify option button gradient treatment across all three apps via the shared component
- Implement endowment-effect progress bar that reaches 100% only on the success page
- Eliminate the report page dead-end with back navigation and restart action
- Make the back-button text in the question runner clearly visible
- Remove the text-only answer summary from the thank-you page (keep the radar chart)
- Add a "Gerar relatório" action alongside "Adicionar informações" on the thank-you page

**Non-Goals:**
- Changing the radar chart, color palette, or thank-you page layout structure
- Modifying backend APIs or data models
- Changing how `SurveyOptionColors.palette` values are computed in `app_theme.dart`
- Modifying survey-frontend or survey-builder specific pages beyond shared components

## Decisions

### D1: Gradient direction and implementation strategy

Use `LinearGradient` with `begin: Alignment.topLeft` and `end: Alignment.bottomRight` on the `ElevatedButton` background in `SurveyOptionButton`. Each palette color gets a gradient pair: the base color (top-left) darkened by ~12% (bottom-right). This is applied at the widget level, not in the palette definition, so `SurveyOptionColors` stays a flat color list and the gradient is computed per-button.

**Alternatives considered:**
- Mesh gradients via `CustomPaint`: Too complex for buttons, harder to maintain, performance cost
- Theme-level `BoxDecoration`: Would require changing the entire theme, not just option buttons
- ShaderMask overlay: Adds unnecessary compositing layers

### D2: Progress bar denominator and formula

Change `DsSurveyProgressIndicator` to accept an optional `includeSuccessPage: true` parameter (default `false` for backward compatibility). When true, the denominator becomes `total + 1` and the formula is:
- `progress = max(0.02, (currentIndex + 1) / (total + 1))` for current questions
- `progress = 1.0` when `onSuccessPage` is explicitly set or `currentIndex == total`

This keeps the API backward-compatible: existing callers that don't pass `includeSuccessPage` get the old behavior. Only `DsSurveyQuestionRunner` and its consuming apps opt into the new behavior.

**Alternatives considered:**
- Always using `total + 1`: Breaking change for all consumers
- Using a standalone percentage value: Loses the declarative index-based API

### D3: Report page back navigation target

Add an `onRestartSurvey` callback to `ReportPage` and reconfigure `DsScaffold.onBack` to pop to the thank-you page. The `backLabel` changes to "Voltar" and a new full-width `DsOutlinedButton` with "Iniciar nova avaliação" is added at the bottom, identical to the one on `thank_you_page.dart`. The parent route provides `onRestartSurvey` by calling the same `restartAssessmentFlow` + `replaceWithEntryGate` pattern.

### D4: Back-button text color in question runner

Replace the `TextButton` with a `TextButton.styleFrom(foregroundColor: Colors.white)` to match the option button text color. No new theme tokens needed.

### D5: Thank-you page answer summary removal

Remove the text-based "Resumo das respostas" loop (lines ~412-451 in `thank_you_page.dart`) while keeping the radar chart and legend chips. The `_AnswerSummary` class and `_buildSummaries` method stay because they feed the radar chart data.

### D6: Adding "Gerar relatório" to DsHandoffFork

Add a second `DsHandoffForkAction` to the `actions` list on `thank_you_page.dart` with `primaryLabel: 'Gerar relatório'` and navigation to the report page via `AppNavigator.toReport`. Both actions render side-by-side in the fork.

## Risks / Trade-offs

- [Gradient rendering on older devices] → `LinearGradient` is GPU-accelerated on all Flutter targets; no known performance concern
- [Progress bar change is backward-compatible but `DsSurveyQuestionRunner` must pass the flag] → All three apps share this component, so each must be updated to pass `includeSuccessPage: true` at the call site
- [Report page back navigation depends on route stack] → If navigated to directly (deep link), the pop may not reach thank-you page; mitigate with named route check
- [Removing answer summary removes data that users might reference] → The radar chart and question labels still provide visual summary; individual answers remain available in the stored response
