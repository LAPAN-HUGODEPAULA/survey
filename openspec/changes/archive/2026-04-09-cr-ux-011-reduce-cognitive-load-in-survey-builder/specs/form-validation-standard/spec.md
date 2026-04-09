## ADDED Requirements

### Requirement: Form-Level Error Summary for Complex Forms
Complex administrative or multi-step forms MUST provide a visible summary of all validation errors at the top of the form (or in a persistent area) in addition to inline field-level errors.

#### Scenario: User attempts to save a form with multiple invalid fields
- **WHEN** the user clicks "Save" or "Next"
- **AND** there are multiple validation failures across different sections
- **THEN** the system MUST display an error summary component near the top of the form or near the primary action area
- **AND** the summary MUST list the fields that need attention
- **AND** clicking an item in the summary SHOULD scroll the view to the corresponding invalid field.
