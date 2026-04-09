## Why

The `survey-builder` application is a high-density administrative surface where users manage complex clinical questionnaires, AI prompts, and persona skills. Currently, long forms lack internal navigation, save states are not persistently visible, and error handling relies heavily on transient snackbars, leading to high cognitive load, fatigue, and a fear of making mistakes during long editing sessions.

## What Changes

- **Sectional Navigation**: Introduce a local table of contents or sidebar navigation for long builder forms (Questionnaires, Prompts, Personas) to allow quick jumping between sections.
- **Persistent Save State**: Implement a sticky save/cancel area and a persistent "Unsaved Changes" indicator to provide continuous feedback on the state of the work.
- **In-Context Error Handling**: Transition from snackbar-only error messages to inline validation errors and form-level error summaries, ensuring errors are shown where they can be corrected.
- **Enhanced CRUD Feedback**: Improve list views for prompts and personas with clearer empty states, filter affordances, and "Saved/Conflict" status indicators.
- **Visual Wayfinding**: Use clearer sectional headers and visual grouping to break up dense administrative forms.

## Capabilities

### New Capabilities
- `builder-productivity-ux`: Covers the implementation of sectional navigation, persistent save indicators, and improved CRUD feedback specific to the administrative context of `survey-builder`.

### Modified Capabilities
- `frontend-survey-builder`: Update the main builder interface requirements to include sectional wayfinding and persistent state management.
- `full-survey-editing`: Modify requirements for the survey editor to include inline error summaries and sticky action areas.
- `form-validation-standard`: Extend the platform-wide form validation standard to specify the use of inline errors and summaries in administrative contexts.
- `multi-step-progress-standard`: Apply multi-step progress principles to long, single-page administrative forms through sectional navigation.

## Impact

- **Affected Apps**: `survey-builder`
- **Affected Packages**: `packages/design_system_flutter` (potential new shared components for sticky bars or sectional nav)
- **Affected Specs**: `frontend-survey-builder`, `full-survey-editing`, `form-validation-standard`, `multi-step-progress-standard`
