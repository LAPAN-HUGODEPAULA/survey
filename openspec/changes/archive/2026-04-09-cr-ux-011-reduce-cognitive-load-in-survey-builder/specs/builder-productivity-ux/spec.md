## ADDED Requirements

### Requirement: Sectional Navigation for Long Administrative Forms
The `survey-builder` application SHALL provide a sectional navigation component (e.g., a table of contents or sidebar) for long editing forms (Questionnaires, Prompts, Personas) to allow users to navigate between sections without exhaustive scrolling.

#### Scenario: User navigates using the sectional menu
- **WHEN** the user is editing a long survey or persona form
- **THEN** a navigation menu MUST be visible, listing all major sections of the form
- **AND** clicking a section name MUST scroll the view to that section immediately
- **AND** the menu MUST highlight the current active section as the user scrolls.

### Requirement: Persistent Save and Action Area
The `survey-builder` editing screens MUST include a persistent (sticky) action area that remains visible regardless of scroll position, containing at least the "Save" and "Cancel" actions.

#### Scenario: User scrolls a long form
- **WHEN** the user scrolls down a long questionnaire editor
- **THEN** the "Save" and "Cancel" buttons MUST remain anchored to the bottom or top of the viewport
- **AND** the "Save" button MUST remain enabled or disabled based on the form's current validation state.

### Requirement: Visual Unsaved Changes Indicator
The `survey-builder` application MUST persistently display the "Unsaved Changes" state whenever the current form has been modified but not yet successfully persisted to the backend.

#### Scenario: User modifies a field
- **WHEN** the user changes any value in an administrative form
- **THEN** a clear visual indicator (e.g., a status chip or text label) MUST appear near the save action saying "Alterações não salvas" (Unsaved changes)
- **AND** the indicator MUST update to "Salvando..." (Saving) during the write operation
- **AND** it MUST update to "Alterações salvas" (Changes saved) or disappear after a successful save.

### Requirement: Enhanced CRUD List Affordances
List views for administrative catalogs (Surveys, Prompts, Personas) MUST include clear empty states, search/filter affordances, and status indicators for items that have pending conflicts or recent updates.

#### Scenario: User views an empty catalog
- **WHEN** a catalog (e.g., Persona Skills) has no items
- **THEN** the system MUST display a descriptive empty state explaining why it's empty
- **AND** it MUST provide a clear "Create" action within the empty state container.

#### Scenario: User filters a list
- **WHEN** the user enters text in a search or filter field for a catalog
- **THEN** the list MUST update in real-time to show only matching items
- **AND** if no matches are found, a "No results" message MUST be shown with an option to clear the filter.
