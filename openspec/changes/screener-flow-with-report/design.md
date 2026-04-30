## Context

The `survey-frontend` (screener) app was built before `survey-patient` and has accumulated UI inconsistencies and missing features. The patient app received a polished flow with shared components from `design_system_flutter`, but the screener app still uses legacy patterns: a custom stepper widget, inline medication API calls, duplicated instructions page code, and no AI-powered report generation on the thank-you page.

The backend already supports agent access points, prompt catalogs, and persona skills. The `survey-patient` app has working implementations of the thank-you page with preliminary assessment, report generation, and email delivery. The goal is to bring parity to the screener flow by reusing proven patterns and shared components.

**Current state of key files:**
- `survey-frontend`: Uses `AssessmentFlowStepper` (custom widget) and `DsSection`-based settings page for questionnaire selection
- `survey-patient`: Uses `PatientJourneyStepper` (polished, shared component) with working instructions scroll
- `design_system_flutter`: Has `DsMedicationAutocompleteField` that calls the API per keystroke
- Backend: Has `agent_access_points` collection, medication search API, clinical writer async task system

## Goals / Non-Goals

**Goals:**
- Eliminate per-session questionnaire selection by making it an admin-configurable default
- Achieve visual parity between screener and patient stepper components
- Fix the broken medication autocomplete with a load-all-then-filter approach
- Share the instructions page component between apps
- Add AI preliminary assessment and report generation to the screener thank-you page
- Provide clinical document generation (referral letters) from the screener report page
- Centralize page titles in AppBar across screener pages

**Non-Goals:**
- Modifying the patient app's existing flow (only extracting shared components)
- Changing the backend clinical writer processing logic
- Redesigning the radar chart component
- Adding new prompt templates or persona skills (reusing existing ones)
- Changing the screener authentication or session management

## Decisions

### 1. Default questionnaire stored as system setting, not per-screener preference

**Decision:** Store the default questionnaire ID in a `system_settings` MongoDB collection with key `screener_default_questionnaire_id`, managed via survey-builder admin UI, with bootstrap fallback to `CHYPS-V Br Q20` when no explicit setting exists.

**Alternative considered:** Per-screener preference stored in user profile. Rejected because the organization typically uses one standard questionnaire; per-user prefs add complexity without proportional benefit.

**Rationale:** A single system-wide setting is simpler, avoids screener confusion about which questionnaire they're using, and matches the organizational workflow where one questionnaire (`CHYPS-V Br Q20`) is standard.

### 2. Extract shared stepper component into design_system_flutter

**Decision:** Create a `DsFlowStepper` widget in `design_system_flutter` that both `PatientJourneyStepper` and the screener stepper use. The existing `PatientJourneyStepper` becomes a thin wrapper or is replaced entirely.

**Alternative considered:** Copy the patient stepper code into survey-frontend. Rejected to avoid code duplication.

**Rationale:** Single source of truth for stepper UI; any future design changes propagate to both apps automatically.

### 3. Medication autocomplete: load-all on first focus, filter in memory

**Decision:** Add a `GET /v1/medications` endpoint (or reuse existing search with no query param) that returns all medications. The autocomplete widget loads the full list on first focus, stores it in a `List<Medication>` field, and filters locally on each keystroke.

**Alternative considered:** Paginated load + infinite scroll. Rejected because the ANVISA list is small (~50-100 items).

**Rationale:** The medication list is small enough to hold in memory. This eliminates network latency per keystroke and the "too many requests" problem.

### 4. Share instructions page via design_system_flutter component

**Decision:** Extract the working instructions page from `survey-patient` into a `DsInstructionsSection` widget in `design_system_flutter`, then use it in both apps.

**Alternative considered:** Fix the scroll bug in `survey-frontend`'s instructions page independently. Rejected because the implementations should be shared to prevent future drift.

### 5. Reuse existing access point infrastructure for screener reports

**Decision:** Create new access point entries in the `agent_access_points` collection for screener-specific report generation and clinical document generation. The screener thank-you page resolves access points the same way `survey-patient` does.

**Rationale:** The access point system already handles prompt + persona binding, resolution precedence, and builder UI configuration. No new infrastructure needed.

### 6. Screener report page extends survey-patient report page pattern

**Decision:** Create `report_page.dart` in `survey-frontend` modeled after `survey-patient`'s report page, adding buttons for email delivery, clinical referral, school referral, and parent orientation.

**Rationale:** The async task polling, error handling, and PDF export logic is already proven in the patient app. The screener page adds action buttons for clinical document types specific to the professional workflow.

## Risks / Trade-offs

- **[Risk] Loading all medications may be slow on first focus** → Mitigation: The list is ~50-100 items, returning as a single JSON response (~5-10KB). Add a local in-memory cache that persists for the session. Show a brief loading indicator on first focus only.

- **[Risk] Shared stepper component may not fit both flows exactly** → Mitigation: Use configuration props (step names, colors, callbacks) to customize behavior while keeping the visual design consistent. If divergence is needed, use composition over inheritance.

- **[Risk] New access points may conflict with existing ones** → Mitigation: Use a clear naming convention (`screener.*` prefix) and the existing duplicate-key handling in survey-builder (detect existing → update mode).

- **[Risk] Screener settings section in survey-builder requires new UI** → Mitigation: Add a simple settings page with a questionnaire dropdown. Reuse existing `DsSection` patterns from other builder admin pages.

- **[Trade-off] Centralized AppBar titles require touching every page** → This is intentional for consistency. Each page's AppBar title is set individually; no global configuration needed.
