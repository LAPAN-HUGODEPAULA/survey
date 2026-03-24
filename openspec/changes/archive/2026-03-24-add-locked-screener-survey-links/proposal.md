# Change: Add locked screener questionnaire access links

## Why
The current `survey-frontend` flow requires manual setup before each assessment. In practice, operators often need to prepare one screener and one questionnaire in advance, then hand over a single link or QR code that opens the app already configured and prevents accidental changes by non-technical users.

## What Changes
- Add a reusable backend-generated access link for a specific screener and questionnaire pair.
- Add `survey-frontend` controls to generate, copy, and export the access link as plain text and QR code (`PNG`).
- Add a locked launch mode in `survey-frontend` that opens the app with the screener and questionnaire preselected and hides or disables setup controls.
- Add a non-technical unavailable page when a link points to a screener or questionnaire that is no longer available.
- Preserve support for multiple links per screener across different questionnaires, while keeping the common case simple.
- Emphasize usability and accessibility for low-technical-skill users across link generation, entry, and failure states.

## Impact
- Affected specs: `survey-association`, `screener-survey-access-links`
- Affected code:
  - `apps/survey-frontend/lib/**` for settings UI, routing, launch-state handling, QR/text export, and locked setup behavior
  - `services/survey-backend/app/**` for link persistence, validation, and resolution APIs
  - `packages/contracts/survey-backend.openapi.yaml` and generated Dart SDKs for new endpoints/models
