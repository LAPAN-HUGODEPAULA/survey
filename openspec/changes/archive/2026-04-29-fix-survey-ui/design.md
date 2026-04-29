## Context

The respondent journey in `survey-patient` and `survey-frontend` depends on shared primitives from `packages/design_system_flutter`. Recent usability feedback identified four concrete issues: low-contrast status and button colors, non-scrollable section content on small devices, inconsistent radar scoring semantics, and unreadable radar labels. Because these concerns are shared across applications, implementation must prioritize design-system token and component changes, with app wrappers only adjusting screen-specific copy and wiring.

## Goals / Non-Goals

**Goals:**
- Improve text and control readability to meet a minimum 6:1 contrast ratio for the reported surfaces.
- Ensure long survey content is reachable on low-resolution devices via vertical scrolling.
- Standardize thank-you radar scoring to a deterministic `0..3` scale mapped from response options.
- Apply radar readability and scaling behavior consistently in both respondent apps.
- Keep changes localized to shared components and page wrappers without backend contract changes.

**Non-Goals:**
- Redesigning the overall visual identity, typography, or layout hierarchy.
- Changing questionnaire content model, API payload shape, or backend scoring rules.
- Introducing new navigation flows or changing handoff step sequencing.

## Decisions

1. **Token-first contrast adjustment in design system**
   - Decision: Update shared color tokens and/or component-level style constants in `design_system_flutter` for status text chips and survey answer button fills.
   - Rationale: These surfaces are reused and must stay consistent across apps; token changes minimize drift and local overrides.
   - Alternative considered: Local color overrides in each app page. Rejected because it duplicates logic and risks future divergence.

2. **Enforce contrast at component boundaries, not page-specific text styles**
   - Decision: Keep page code thin and enforce contrast where visual surfaces are defined (`DsSurveyQuestionData`, shared status metadata widgets).
   - Rationale: Shared components are the source of truth and easier to regression test once.
   - Alternative considered: Per-page style patching in `welcome_page.dart` and `survey_page.dart`. Rejected due to inconsistent adoption risk.

3. **Scroll enablement in shared section container**
   - Decision: Add opt-in/default vertical scrolling in the shared section wrapper (`DsSection` or equivalent section container used by respondent screens).
   - Rationale: Device-resolution issues are layout-level concerns and should be solved by shared shell primitives.
   - Alternative considered: Wrapping individual pages with `SingleChildScrollView`. Rejected because it leads to repeated fixes and mixed behaviors.

4. **Central radar normalization and label readability treatment**
   - Decision: Apply response-to-score mapping (`Quase nunca=0`, `Ocasionalmente=1`, `Frequentemente=2`, `Quase sempre=3`) in shared radar mapping/render helpers and set radar max range to `3`.
   - Rationale: A single mapping source avoids app divergence and ensures comparable plots between `survey-patient` and `survey-frontend`.
   - Alternative considered: App-specific mappings in each thank-you page. Rejected due to inconsistency risk.

5. **Radar label legibility via contrast-backed label chips**
   - Decision: Render radar axis labels with darkened label backgrounds and high-contrast light text.
   - Rationale: Axis text sits over complex chart backgrounds and needs explicit contrast treatment independent of surrounding surfaces.
   - Alternative considered: Only increasing font weight/size. Rejected because contrast, not size, is the main readability failure.

## Risks / Trade-offs

- **[Risk] Contrast updates alter visual tone beyond target surfaces** → Mitigation: limit color changes to affected tokens/components and verify unchanged screens visually.
- **[Risk] New scroll container interferes with existing nested scrolling** → Mitigation: apply scroll behavior at the correct level and test low-resolution + typical desktop viewport flows.
- **[Risk] Radar mapping change affects perceived result trends** → Mitigation: document explicit ordinal mapping and verify expected values with sample responses.
- **[Risk] Label backgrounds may occlude chart details when many axes exist** → Mitigation: use compact chip padding and preserve spacing/opacity balance during QA.
