## Why

The `survey-builder` has serious navigation problems for administrative work, including dead-end flows such as the skills screen with no clear path back to the main administration surface. As the builder grows to manage prompts, personas, and access points, these usability gaps will directly slow down configuration work and increase operator error.

## What Changes

- Introduce a consistent admin navigation shell for `survey-builder`.
- Add clear home, back, and section-navigation affordances across survey, prompt, and persona administration screens.
- Make catalog screens reachable from a stable dashboard instead of only through floating action buttons on the survey list.
- Ensure the navigation model scales to new admin sections such as access-point management and audit review.
- Improve route orientation, empty states, and return paths so no admin screen becomes a dead end.

## Capabilities

### New Capabilities
- `builder-admin-navigation-shell`: Shared navigation model for all builder administration areas.

### Modified Capabilities
- `frontend-survey-builder`: Reorganize the builder information architecture around a stable admin shell.
- `builder-productivity-ux`: Reduce friction in long-lived admin workflows and catalog management tasks.
- `user-navigation-orientation`: Add explicit orientation and return paths to builder administration flows.

## Impact

- Affected apps: `apps/survey-builder`
- Affected design system usage: shared scaffold, admin shells, persistent navigation surfaces
- Affected docs: builder user guidance and screenshots
- Dependencies: builder authentication entry flow, future admin sections
