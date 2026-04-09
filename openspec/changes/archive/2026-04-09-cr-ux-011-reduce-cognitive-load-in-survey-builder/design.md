## Context

The `survey-builder` application handles complex, dense administrative forms. The current implementation of `DsAdminFormShell` places primary actions (Save/Cancel) at the top, forcing users to scroll back up to save after editing long forms. Additionally, feedback is often transient (snackbars), leading to missed validation errors.

## Goals / Non-Goals

**Goals:**
- Improve wayfinding in long forms via sectional navigation.
- Ensure primary actions are always accessible via sticky footers.
- Provide persistent feedback on save/unsaved state.
- Improve error visibility via form-level summaries and inline validation.
- Enhance list management with search and clearer empty states.

**Non-Goals:**
- Re-architecting the backend API (though API support for better errors is a separate CR).
- Changing the fundamental data model of surveys or personas.

## Decisions

### 1. Sticky Action Bar in `DsAdminFormShell`
**Decision:** Modify `DsAdminFormShell` to support an optional sticky footer containing the primary actions (Save/Cancel).
**Rationale:** Long forms require the user to scroll significantly. Keeping the "Save" action visible reduces friction and cognitive load.
**Alternatives:** 
- Sticky Header: Already supported, but headers are often crowded with navigation and titles.
- Float buttons: Less standard for dense administrative forms.

### 2. `DsSectionalNav` Component
**Decision:** Create a new shared component that renders a list of sections and handles programmatic scrolling to `GlobalKey` or `index` positions.
**Rationale:** Provides immediate jumping capability and visual orientation (table of contents).
**Implementation:** Use `Scrollable.ensureVisible` for jumping.

### 3. Persistent "Unsaved Changes" State
**Decision:** Add a `hasUnsavedChanges` flag to the admin shells and display a status indicator (e.g., `DsStatusChip` or simple text) next to the "Save" button.
**Rationale:** Reassures the user about the state of their work and prevents accidental loss of data.

### 4. `DsErrorSummary` Component
**Decision:** Implement a component that aggregates all active validation errors and displays them at the top of the form.
**Rationale:** When a form has many fields, a single snackbar saying "Check errors" is not enough. A summary provides a checklist for the user.
**Implementation:** Collect errors from `FormState` or a custom validation controller.

### 5. Enhanced `DsAdminCatalogShell` with Search/Filter
**Decision:** Add a `searchController` and `onSearchChanged` callback to `DsAdminCatalogShell`.
**Rationale:** As the number of prompts and personas grows, listing them all becomes inefficient.

## Risks / Trade-offs

- **[Risk]** Sticky footers taking up too much vertical space on small screens. → **Mitigation:** Use a compact design and ensure it doesn't obscure content.
- **[Risk]** Sectional navigation getting out of sync with actual scroll position. → **Mitigation:** Use a `NotificationListener<ScrollNotification>` to update the active section in the menu.
- **[Risk]** Complex validation state management for summaries. → **Mitigation:** Leverage Flutter's `Form` and `FormField` state, or introduce a simple `ValidationProvider`.
