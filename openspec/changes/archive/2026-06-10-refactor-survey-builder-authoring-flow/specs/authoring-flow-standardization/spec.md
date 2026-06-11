## ADDED Requirements

### Requirement: Separation of Concerns in Authoring Forms
Administrative forms in `survey-builder` MUST separate UI rendering from business logic, validation, and data persistence.

#### Scenario: Form Page uses dedicated Controller
- **WHEN** an admin navigates to an authoring page (Survey, Access Point, AI Agent, or Persona Skill)
- **THEN** the Page widget SHALL delegate state management and repository interactions to a dedicated Controller or ViewModel.

### Requirement: Centralized Form Validation
Validation logic for administrative forms SHALL be centralized and reusable, decoupled from the UI widgets.

#### Scenario: Validation feedback in Authoring Forms
- **WHEN** an admin submits an authoring form with invalid data
- **THEN** the system SHALL provide a validation summary and highlight specific fields using centralized validation rules.

### Requirement: Local Draft Persistence
The system SHALL maintain a consistent mechanism for local draft persistence across all major authoring flows.

#### Scenario: Automatic local draft restoration
- **WHEN** an admin reopens an authoring form that was previously closed with unsaved changes
- **THEN** the system SHALL prompt for or automatically restore the local draft state.
