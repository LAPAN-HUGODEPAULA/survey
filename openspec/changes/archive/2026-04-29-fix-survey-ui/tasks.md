## 1. Survey Page Copy and Layout Accessibility

- [x] 1.1 Remove `"Olá! Estamos com você em cada etapa."` from `apps/survey-patient/lib/features/welcome/pages/welcome_page.dart` without changing the start action flow.
- [x] 1.2 Ensure respondent section content can scroll on low-resolution devices by updating shared section/container behavior in `packages/design_system_flutter` and validating usage in patient survey pages.

## 2. Shared Contrast Improvements in Design System

- [x] 2.1 Update shared status/progress metadata styles in `packages/design_system_flutter` so orange text on card/surface backgrounds reaches at least 6:1 contrast.
- [x] 2.2 Update the four survey answer option button colors used by `DsSurveyQuestionData` so white text contrast is at least 6:1 for each option.

## 3. Radar Scale and Label Readability

- [x] 3.1 Update radar score normalization to fixed `0..3` range with mapping: `Quase nunca=0`, `Ocasionalmente=1`, `Frequentemente=2`, `Quase sempre=3`.
- [x] 3.2 Improve radar label readability using high-contrast label rendering and apply consistently to both `apps/survey-patient` and `apps/survey-frontend` thank-you flows.

## 4. Validation and Change Hygiene

- [x] 4.1 Run `flutter analyze` for affected apps (`apps/survey-patient` and `apps/survey-frontend`) and resolve any regressions introduced by this change.
- [x] 4.2 Run targeted validation for the design system package and confirm only intentional diffs remain in OpenSpec artifacts and code changes.
