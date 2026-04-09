## 1. Shared Auth Foundation

- [x] 1.1 Define shared professional auth widgets in `packages/design_system_flutter` for sign-in, sign-up, and standard auth feedback states
- [x] 1.2 Extract a shared right-side account menu component or menu contract in `packages/design_system_flutter` without coupling it to app-specific navigation or providers
- [x] 1.3 Add or update shared exports and any supporting UI documentation needed for the new auth components

## 2. Survey Frontend Adoption

- [x] 2.1 Refactor `survey-frontend` sign-in and sign-up pages to consume the shared auth UI while preserving the existing screener backend integration
- [x] 2.2 Update `survey-frontend` account-menu composition to use the shared menu behavior while retaining profile and settings entries where supported
- [x] 2.3 Add or tighten `survey-frontend` auth guards so protected professional routes require login and `/access/:token` remains publicly accessible

## 3. Clinical Narrative Authentication

- [x] 3.1 Add screener session state and backend auth integration to `clinical-narrative` using the existing screener login, registration, and profile endpoints
- [x] 3.2 Replace the local clinician credential entry screen with the shared sign-in/sign-up experience backed by real screener authentication
- [x] 3.3 Add the shared right-side account menu to `clinical-narrative` and implement logout and account-switch behavior for authenticated sessions
- [x] 3.4 Gate `clinical-narrative` protected workflows behind authenticated screener entry without rewriting unrelated workflow pages

## 4. Verification

- [x] 4.1 Add or update tests covering protected-entry behavior, public locked-link behavior, and shared menu/session actions where practical
- [x] 4.2 Run `flutter analyze` for `apps/survey-frontend`, `apps/clinical-narrative`, and `packages/design_system_flutter`
- [x] 4.3 Perform UI validation of the shared auth screens and account menu in both apps for visual consistency, accessibility, and responsive behavior
