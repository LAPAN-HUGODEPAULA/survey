## 1. Shared Design System Components

- [x] 1.1 Create `DsSectionalNav` component in `packages/design_system_flutter/lib/components/admin/`.
- [x] 1.2 Create `DsErrorSummary` component in `packages/design_system_flutter/lib/components/forms/`.
- [x] 1.3 Update `DsAdminFormShell` to support an optional sticky footer for primary actions.
- [x] 1.4 Add `hasUnsavedChanges` and `isSaving` indicator support to `DsAdminFormShell`.
- [x] 1.5 Update `DsAdminCatalogShell` to include search/filter input area and callbacks.

## 2. Survey Builder App Enhancements - Forms

- [x] 2.1 Integrate `DsSectionalNav` into the Questionnaire editor (`SurveyFormScreen`).
- [x] 2.2 Update Questionnaire editor to use the sticky footer and unsaved changes indicator.
- [x] 2.3 Add `DsErrorSummary` to the Questionnaire editor to display validation failures.
- [x] 2.4 Implement sectional navigation and sticky actions in the Persona Skill editor.
- [x] 2.5 Implement sectional navigation and sticky actions in the Reusable Prompt editor.

## 3. Survey Builder App Enhancements - Catalogs

- [x] 3.1 Add search/filtering to the Survey list screen.
- [x] 3.2 Add search/filtering to the Persona Skill catalog screen.
- [x] 3.3 Add search/filtering to the Reusable Prompt catalog screen.
- [x] 3.4 Improve empty state illustrations and call-to-actions across all administrative catalogs.

## 4. Validation and Feedback

- [x] 4.1 Ensure all administrative forms in `survey-builder` show inline validation errors for all fields.
- [x] 4.2 Replace generic "Check errors" snackbars with specific form-level error summaries.
- [x] 4.3 Verify that clicking an error in the summary scrolls the user to the corresponding field.

## 5. Verification

- [x] 5.1 Manual verification of sectional navigation smooth scrolling and active section highlighting.
- [x] 5.2 Manual verification of sticky footer behavior on different screen heights.
- [x] 5.3 Automated or manual verification of "Unsaved Changes" logic (dirty state detection).
- [x] 5.4 Regression testing of survey creation and update flows.
