## 1. Navigation architecture

- [x] 1.1 Define the `survey-builder` administrative information architecture, including the home/dashboard screen, primary sections, and route ownership for each admin area.
- [x] 1.2 Implement a shared admin shell that hosts section navigation, page framing, and a stable path back to the home context.
- [x] 1.3 Preserve or adapt existing builder routes so legacy entries resolve into the new shell without breaking deep links.

## 2. Screen integration

- [x] 2.1 Move survey, prompt, and persona catalog screens under the shared shell and add explicit home and parent-context affordances.
- [x] 2.2 Update nested editor screens to show breadcrumbs or contextual back actions plus stable section titles after navigation and save operations.
- [x] 2.3 Add orientation-friendly empty states and section entry points so secondary catalogs are reachable without relying on unrelated screens.

## 3. Validation and polish

- [x] 3.1 Add widget or navigation tests covering return-to-home behavior, nested-editor back paths, and deep-linked builder routes.
- [x] 3.2 Validate the shell on desktop and lower-resolution layouts so the navigation model remains usable as more admin sections are added.
- [x] 3.3 Update builder user guidance and screenshots to reflect the new navigation shell and home/dashboard structure.
