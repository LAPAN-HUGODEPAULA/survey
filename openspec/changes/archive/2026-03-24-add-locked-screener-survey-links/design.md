# Design: Locked screener questionnaire access links

## Context
`survey-frontend` currently keeps screener session state and the selected questionnaire in `AppSettings`, and the setup screen allows the questionnaire to be changed manually. There is no existing concept of a shareable launch configuration, no route-level preload for screener/questionnaire context, and no spec coverage for a user-friendly unavailable state when linked resources are removed.

## Goals
- Let an operator generate a reusable URL for one screener and one questionnaire.
- Make the URL safe to share without exposing raw screener/questionnaire identifiers in the browser address.
- Open the app directly in a locked mode that prevents changing the screener or questionnaire.
- Keep the experience simple for users with weak technological skills.
- Provide a clear, non-technical unavailable page if the link can no longer be honored.

## Non-Goals
- Time-based expiration or revocation workflows.
- Replacing normal screener login flows for regular administrative use.
- General-purpose public survey sharing for `survey-patient`.

## Proposed Approach
Use an opaque backend-generated token stored in a dedicated access-link record. The record binds:
- screener identifier
- questionnaire identifier
- status metadata needed to decide whether the link is still usable
- display metadata useful for frontend confirmation and exports

`survey-frontend` receives the token through a route or query parameter, calls a backend resolution endpoint, and hydrates `AppSettings` with a locked launch configuration. In locked mode:
- the questionnaire is preselected
- the screener context comes from the resolved link, even without an authenticated session
- setup entry points are hidden or disabled
- submission uses the linked screener identity for survey association

If resolution fails because the token is unknown, the screener no longer exists, or the questionnaire is no longer available, the app shows an informational unavailable page instead of a technical error page. The page should explain what happened in plain Portuguese and direct the user to contact the current screener or `lapan.hugodepaula@gmail.com`.

## Key Decisions

### Opaque token instead of plain IDs
The chosen approach avoids exposing screener and questionnaire identifiers in shared URLs and gives the backend freedom to evolve the stored association without changing public URLs.

### Reusable links with no expiration
The requested default is persistent links. Backend validation therefore becomes the control point: the link remains reusable until the associated screener or questionnaire becomes unavailable.

### Multiple links supported
The data model and API should allow more than one link per screener overall and more than one link lifecycle event in the future, even if the common use case is a single active link for a screener-questionnaire pair.

### Locked mode is a launch mode, not a login mode
The link opens the app without authentication. It provides assessment context only. It should not unlock profile or administrative actions that belong to authenticated screeners.

## UX and Accessibility Considerations
- Use simple, task-oriented language in pt-BR and avoid technical terms such as "token inválido".
- Keep generation flow linear: confirm screener, confirm questionnaire, generate link, then expose obvious actions for copy, text export, and QR code export.
- Export the QR code as `PNG` to keep the download format familiar and easy to use for non-technical operators.
- Clearly label the page as a prepared assessment link so users understand why setup controls are unavailable.
- Provide large touch targets, visible status feedback after copy/export actions, and high-contrast QR download affordances.
- Ensure locked-state indicators and unavailable-page messaging are screen-reader friendly and keyboard accessible.

## Risks and Mitigations
- Hidden setup controls may confuse operators who expected the normal menu.
  - Mitigation: include an explicit locked-mode banner that explains the session was opened from a prepared link.
- A deleted screener or questionnaire could otherwise fail as a blank screen or generic API error.
  - Mitigation: specify a dedicated unavailable page with recovery instructions.
- Using link-based screener attribution without login could blur administrative versus assessment permissions.
  - Mitigation: constrain the link to assessment context only and keep profile/settings actions behind normal authentication.

## Affected Areas
- Backend models and repositories for access-link persistence and lookup
- Backend routes and OpenAPI contract for create/resolve operations
- `survey-frontend` routing, `AppSettings`, settings UI, and setup visibility rules
- Survey submission flow so linked launches are attributed to the resolved screener
