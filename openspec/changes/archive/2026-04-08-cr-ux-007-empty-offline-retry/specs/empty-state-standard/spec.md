## ADDED Requirements

### Requirement: Empty State Explanation (DsEmptyState)
All data-driven lists or screens that do not have content SHALL present a standardized explanation through the `DsEmptyState` component in Brazilian Portuguese (pt-BR).

#### Scenario: View empty questionnaire catalog
- **WHEN** the user accesses the catalog and no questionnaires are registered
- **THEN** the system SHALL display a `DsEmptyState` with: "Nenhum questionário encontrado. Crie o primeiro questionário para começar."

### Requirement: Suggested Action in Empty States
Every `DsEmptyState` SHALL include at least one suggested primary action (Wayfinding) so the user can transition out of the "dead end" state.

#### Scenario: Create first item from empty state
- **WHEN** the system displays an empty state for the patient catalog
- **THEN** the system SHALL present a prominent action button labeled "Novo Paciente" (pt-BR).
