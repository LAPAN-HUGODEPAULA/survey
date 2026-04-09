## 1. Design System: Ambient Empathy Infrastructure

- [x] 1.1 Create `DsToneTokens` `ThemeExtension` with `emotionalVolume` and tone profiles in pt-BR.
- [x] 1.2 Implement `DsEmotionalToneProvider` for context-aware tone propagation.
- [x] 1.3 Add frictionless `userName` support to `DsScaffold` and `DsFeedback` with friendly pt-BR fallbacks.
- [x] 1.4 Integrate `DsAmbientDelight` using primitive-only animations (`Opacity`, `Transform`, `Color`) in success/completion states.

## 2. Application-Specific Tone & Personalization

- [x] 2.1 Apply `patient` tone (High Volume) in `survey-patient` (Welcome, Completion, AI waits).
- [x] 2.2 Apply `professional` tone (Medium Volume) in `survey-frontend` and `clinical-narrative`.
- [x] 2.3 Apply `admin` tone (Low Volume) in `survey-builder` for minimal, precise feedback.
- [x] 2.4 Integrate "Ambient Greetings" in main dashboards and clinical session starts using local state.

## 3. Performance & Content Verification

- [x] 3.1 Verify zero extra interaction steps (clicks/taps) were added for emotional design.
- [x] 3.2 Benchmark "Ambient Delight" animations to ensure 60fps/90fps consistency on low-end devices.
- [x] 3.3 Validate that `userName` fallbacks are naturally integrated into pt-BR microcopy.
- [x] 3.4 Review all humanized AI wait stage labels (CR-UX-005/008) for supportive tone.
