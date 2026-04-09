## 1. Shared legal content and design-system surfaces

- [x] 1.1 Mirror the approved pt-BR legal markdown files into shared Flutter-consumable assets and document or script the sync path from `docs/legal/`.
- [x] 1.2 Implement the shared footer link and full-document legal reader in `packages/design_system_flutter`.
- [x] 1.3 Implement the shared initial-notice acknowledgement surface in `packages/design_system_flutter` with scrollable content, checkbox gating, and callback-based actions.

## 2. Backend screener contract and migration

- [x] 2.1 Extend the screener domain model, repository normalization, and API/OpenAPI profile schema with the nullable `initialNoticeAcceptedAt` field.
- [x] 2.2 Add the authenticated screener acknowledgement endpoint that records the first agreement with a server-generated timestamp and returns the updated profile.
- [x] 2.3 Create the MongoDB migration/backfill for `initialNoticeAcceptedAt` so existing screener documents are preserved and initialized safely.
- [x] 2.4 Regenerate the Dart API client artifacts and verify the contract diff for the screener legal-notice changes.

## 3. Patient app flow integration

- [x] 3.1 Add the shared legal footer and TUPP viewer entry to `apps/survey-patient`.
- [x] 3.2 Gate the `survey-patient` entry flow on the shared initial-notice surface before the welcome screen.
- [x] 3.3 Update the thank-you restart flow in `survey-patient` to clear the patient acknowledgement state and return to the initial-notice screen.

## 4. Professional and builder app integration

- [x] 4.1 Add the shared legal footer and TUPP viewer entry to `apps/survey-frontend`, `apps/clinical-narrative`, and `apps/survey-builder`.
- [x] 4.2 Update `apps/survey-frontend` to check `initialNoticeAcceptedAt` after login and require the shared initial-notice acknowledgement flow when it is missing.
- [x] 4.3 Update `apps/clinical-narrative` to check `initialNoticeAcceptedAt` after login and require the shared initial-notice acknowledgement flow when it is missing.

## 5. Validation

- [x] 5.1 Run `tools/scripts/generate_clients.sh` and confirm the generated contract changes are intentional.
- [x] 5.2 Run `uv run python -m compileall services/survey-backend/app` and validate the screener migration path against current MongoDB expectations.
- [x] 5.3 Run `flutter analyze` for `packages/design_system_flutter`, `apps/survey-patient`, `apps/survey-frontend`, `apps/clinical-narrative`, and `apps/survey-builder`.
