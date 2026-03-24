## 1. Specification
- [x] 1.1 Add a new `screener-survey-access-links` capability covering link generation, locked launch, export options, and unavailable-state behavior.
- [x] 1.2 Update `survey-association` so survey responses opened through generated links are attributed to the linked screener.
- [x] 1.3 Validate the proposal with `openspec validate add-locked-screener-survey-links --strict`.

## 2. Backend Delivery
- [x] 2.1 Define an API-first contract for creating and resolving opaque screener-questionnaire access links.
- [x] 2.2 Add persistence and validation rules for reusable access links, including checks for missing or inactive screener/questionnaire references.
- [x] 2.3 Add backend tests for link creation, link resolution, invalid-token handling, and survey-response attribution.

## 3. Frontend Delivery
- [x] 3.1 Add a settings flow that lets the operator generate, copy, and export a locked access link as URL text and QR code.
- [x] 3.2 Add app launch handling that resolves a valid link into locked screener/questionnaire state and prevents setup changes.
- [x] 3.3 Add an unavailable information page with clear recovery guidance and accessible, low-friction wording for non-technical users.
- [x] 3.4 Add frontend tests for locked setup behavior, export actions, and the unavailable information page.

## 4. Verification
- [x] 4.1 Regenerate API clients and confirm the diff is limited to the contract changes.
- [x] 4.2 Run backend validation and tests, including `python -m compileall services/survey-backend/app`.
- [x] 4.3 Run `flutter analyze` for `apps/survey-frontend` and any targeted widget/unit tests added for the new flow.
