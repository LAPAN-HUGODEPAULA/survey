# Design: Add Platform Legal Notices

## Context
The repository already contains the approved legal source documents in `docs/legal/`, but none of the Flutter apps currently expose them through a shared in-app legal surface. The change is cross-cutting because it affects all four Flutter applications, the shared design-system package, the screener backend contract, the screener MongoDB schema, and migration scripts.

There are two distinct acknowledgement models:

- `survey-patient` is a public flow with no authenticated identity, so the initial notice gate must be enforced entirely in the client experience.
- `survey-frontend` and `clinical-narrative` are professional apps backed by authenticated screener records, so the platform must persist a single acknowledgement timestamp that is shared across both apps.

The repository also already favors shared Flutter UI through `packages/design_system_flutter`, and that package already includes HTML rendering support. At the same time, the legal markdown files live outside Flutter asset bundles, so the implementation needs an explicit strategy for keeping the legal text reusable without maintaining four copies.

## Goals / Non-Goals

**Goals:**
- Expose the full `Termo de Uso e Política de Privacidade` from a common footer in all four Flutter apps.
- Provide a shared, mobile-friendly legal document reading surface and a shared acknowledgement surface through `packages/design_system_flutter`.
- Gate the `survey-patient` entry flow on initial-notice acknowledgement and require the acknowledgement again when the user starts a new assessment from the thank-you page.
- Persist a single platform-wide screener acknowledgement timestamp that is honored by both `survey-frontend` and `clinical-narrative`.
- Introduce the screener schema and migration changes without losing existing data and while keeping the backend tolerant of legacy records during rollout.

**Non-Goals:**
- Capturing a backend-side agreement record for anonymous patient users.
- Adding a full consent-management module, versioned legal-history ledger, or per-document acceptance archive.
- Changing the legal text itself beyond packaging it for in-app display.
- Redesigning unrelated app shells or adding new authentication providers.
- Requiring agreement in `survey-builder` beyond showing the shared footer link to the full terms.

## Decisions

### 1. Keep `docs/legal/*.md` as the authored source of truth and package app-consumable copies through `packages/design_system_flutter`
The authored legal text should continue to live in `docs/legal/`, because it is repository-visible, reviewable, and already referenced by the request. Flutter apps cannot reliably bundle repo-root documents directly as package assets, so the implementation should mirror the approved markdown files into `packages/design_system_flutter/assets/legal/` and load them from the shared package.

Why this over app-local copies:
- it preserves one authored location for legal review
- it avoids drift between four app-specific asset folders
- it matches the requirement for a shared and unique footer/legal experience

Why this over loading raw files from `docs/legal/` at runtime:
- Flutter asset packaging expects files inside package boundaries
- a runtime filesystem dependency would not be portable to web builds

Implementation consequence:
- the change should include a simple sync rule or script so the package asset copies remain aligned with `docs/legal/`
- the shared package becomes the canonical runtime source for pt-BR legal content in Flutter

### 2. Own the footer link, legal reader, and acknowledgement UI in `packages/design_system_flutter`, while keeping orchestration app-owned
`packages/design_system_flutter` should export:
- a shared footer/legal-link widget usable by all four apps
- a shared legal document viewer that can open as a full screen or dialog depending on the app shell
- a shared acknowledgement panel or screen with the scrollable notice body, checkbox, and disabled-until-checked proceed action

Each app should still own:
- where the footer is mounted
- whether the full terms open in a dialog or dedicated page
- how navigation proceeds after acknowledgement
- how screener acknowledgement state is fetched or persisted

Why this over implementing separate screens in each app:
- the legal copy and checkbox semantics must stay identical across apps
- the repository already prefers shared Flutter ownership for repeated cross-app UI
- it reduces future maintenance when the legal documents or styling change

### 3. Add a dedicated screener acknowledgement contract instead of a generic profile patch surface
Professional acknowledgement needs to be persisted exactly once for the whole platform and should use a server-generated timestamp. The screener contract should therefore add a nullable `initialNoticeAcceptedAt` field to the screener profile and introduce a narrow authenticated endpoint dedicated to recording the acknowledgement.

Recommended contract shape:
- `GET /screeners/me` includes `initialNoticeAcceptedAt`
- `POST /screeners/me/initial-notice-agreement` records the current UTC timestamp if it is not set and returns the updated screener profile

Why this over a generic `PATCH /screeners/me`:
- the change only needs one tightly scoped write path
- a dedicated endpoint is easier to validate, audit, and keep idempotent
- it avoids accidentally broadening profile-editing behavior in the same change

Why this over trusting a client-submitted date:
- server timestamps are consistent across apps and less error-prone
- the field represents a platform acknowledgement event, not arbitrary user-editable metadata

### 4. Treat patient acknowledgement as client-side flow state that is reset by “new assessment,” not as a persisted platform record
`survey-patient` has no authenticated identity and the user clarified that browser restart behavior is not part of the required re-prompting model. The patient notice gate should therefore be enforced in the app flow rather than persisted in backend data. The app should hold a client-side acknowledgement flag that allows the welcome/survey flow to proceed and explicitly clears that flag when the thank-you page starts a new assessment.

Why this over storing anonymous acknowledgements on the backend:
- there is no stable patient identity in the public flow
- it would add collection/API complexity without a stated compliance need
- the explicit requirement is about UI gating, not durable consent records for anonymous visitors

Why this over forcing re-acknowledgement on every transient app reload:
- the clarified requirement does not ask for restart-based re-prompting
- keeping the reset tied to “Iniciar nova avaliação” matches the requested workflow boundary

### 5. Render the legal documents inside a constrained, scrollable reader optimized for long-form text
The legal markdown is too long for a single-page raw render in mobile or browser contexts, so the shared viewer should normalize it into a scrollable reading surface with heading hierarchy, smaller body typography, and an obvious close/back action. The acknowledgement screen should reuse the same scrollable content treatment and place the checkbox and primary action outside the document scroll region so users can read and then act without layout jumps.

Why this over a plain browser download or external tab:
- the request requires the full content to open inside the app or a popup
- in-app rendering keeps the experience consistent and avoids navigation loss

Why this over rendering raw markdown text:
- the requirement calls for properly formatted content
- headings, lists, emphasis, and links need readable presentation for legal review

## Risks / Trade-offs
- [Risk: `docs/legal/` and packaged Flutter assets drift] → Mitigation: define one authored source in `docs/legal/` and add a repeatable sync/check step as part of the change.
- [Risk: screener clients and generated SDKs fall out of sync with the new acknowledgement field/endpoint] → Mitigation: update the OpenAPI contract in the same change and regenerate the Dart clients before app integration.
- [Risk: professional apps briefly diverge on when they trigger the notice gate] → Mitigation: make both apps depend on the same `initialNoticeAcceptedAt` profile field and the same shared acknowledgement UI contract.
- [Risk: patient restart semantics remain slightly ambiguous across browser storage strategies] → Mitigation: document that the requirement only mandates re-prompting on first entry and explicit “new assessment,” and choose the narrowest storage mechanism that satisfies that behavior in implementation.
- [Trade-off: the platform stores only the latest screener acknowledgement timestamp, not a historical acceptance ledger] → Mitigation: accept this because the request asks for a single date field and not full consent versioning.

## Migration Plan
1. Mirror the legal markdown documents into shared package assets and add the shared viewer/footer/acknowledgement surfaces in `packages/design_system_flutter`.
2. Extend the screener domain model, API schema, and OpenAPI contract with `initialNoticeAcceptedAt` plus a dedicated acknowledgement endpoint.
3. Add a MongoDB migration that backfills the new screener field as `null` for existing documents and remains safe to run on current data.
4. Regenerate the Dart API client so the professional apps can consume the new screener profile field and acknowledgement write path.
5. Integrate the shared footer into all four apps and wire the shared legal reader to the full TUPP document.
6. Gate `survey-patient` on the initial notice before the welcome screen and clear the local acknowledgement state when the thank-you page starts a new assessment.
7. Gate `survey-frontend` and `clinical-narrative` after screener login by checking `initialNoticeAcceptedAt` and posting acknowledgement when the user agrees.

Rollback strategy:
- the backend field is additive and nullable, so it can remain in MongoDB even if the UI is rolled back
- the professional apps can ignore the new field and endpoint if a frontend rollback is required
- the shared footer/viewer components can be removed from app shells independently without breaking stored data

## Open Questions
None at proposal time. The user clarified app coverage, platform-wide screener acceptance, and the absence of restart-based patient re-prompting.
