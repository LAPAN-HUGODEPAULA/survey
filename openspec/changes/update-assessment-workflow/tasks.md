## 1. Data model & API

- [x] 1.1 Extend the survey question schema with an optional `label` field, expose it on `/surveys/{id}` responses, and allow create/update payloads to set it.
- [x] 1.2 Write and run a migration that derives fallback labels from existing question text (e.g., key phrases like “Luzes pulsantes”) and persists them while leaving future labels editable.
- [x] 1.3 Add automated tests or contract checks ensuring the new label field round-trips through the backend APIs and defaults to `Q#` when missing.

## 2. Survey builder

- [x] 2.1 Show a label input in the question editor and include the entered label in the save payload sent to the backend.
- [x] 2.2 Surface the label inside question listings/previews so editors can see what patients will read in the radar.
- [x] 2.3 Reload saved surveys with their labels and ensure builders can edit/save the labels repeatedly without losing other question metadata.

## 3. Patient assessment UI

- [x] 3.1 Replace the thank-you grid with the new “Avaliação preliminar” card that fetches the agent response inline (loading + error states) and keeps “Adicionar informações” available.
- [x] 3.2 Modernize the radar to use colors and the `label` metadata, falling back to `Q#` when a label is absent.
- [x] 3.3 Remove the “Ver resultados” button, add an “Iniciar nova avaliação” action that clears survey/agent state, and reuse the existing report flow for “Adicionar informações”.

## 4. Verification & polish

- [x] 4.1 Update or add widget/integration tests covering the new thank-you layout, radar labels, and the “Iniciar nova avaliação” navigation.
- [x] 4.2 Run `flutter analyze`/`flutter test` for `survey-patient`, `survey-builder`, and enforce backend API contract checks to confirm the label field and new UI behave as expected.
