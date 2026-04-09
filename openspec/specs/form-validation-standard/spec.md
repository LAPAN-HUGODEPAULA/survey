# form-validation-standard Specification

## Purpose
TBD - created by archiving change cr-ux-003-form-standardization. Update Purpose after archive.

## Requirements
### Requirement: Consistent Validation Lifecycle
All migrated structured forms MUST follow the same validation cycle to reduce inconsistency between apps and avoid premature hostile errors.

#### Scenario: First typing in a field
- **WHEN** a user starts typing in a field for the first time
- **THEN** the system MUST NOT display a "required field" or incomplete format error during this initial typing

#### Scenario: Field loses focus (blur)
- **WHEN** the field loses focus (blur)
- **THEN** the system MUST validate this field

#### Scenario: Form submission attempt
- **WHEN** the user clicks "Submit" or "Next"
- **THEN** the system MUST validate all relevant fields at that moment

#### Scenario: Re-editing an invalid field
- **WHEN** the user edits a field that has already been marked as invalid
- **THEN** the system MAY revalidate this field during subsequent edits
- **AND** MUST NOT continuously revalidate fields that are still pristine or have never been exposed as invalid

### Requirement: Clear Field-Level Error Messages
Field-level error messages MUST be clear, objective, and indicate the necessary corrective action.

#### Scenario: Date format error
- **WHEN** the user enters an invalid date
- **THEN** the system SHALL display "Use the format DD/MM/YYYY." instead of "Invalid value."

### Requirement: Form-Level Error Summary for Complex Forms
Complex administrative or multi-step forms MUST provide a visible summary of all validation errors at the top of the form (or in a persistent area) in addition to inline field-level errors.

#### Scenario: User attempts to save a form with multiple invalid fields
- **WHEN** the user clicks "Save" or "Next"
- **AND** there are multiple validation failures across different sections
- **THEN** the system MUST display an error summary component near the top of the form or near the primary action area
- **AND** the summary MUST list the fields that need attention
- **AND** clicking an item in the summary SHOULD scroll the view to the corresponding invalid field.

### Requirement: Centralized Validation Logic
The behaviors for `pristine`, `touched`, `submitted`, and revalidation MUST be centralized in `packages/design_system_flutter` to avoid divergent implementations per application.

#### Scenario: Use standard validator in different apps
- **WHEN** a developer implements a form in `survey-builder` and another in `survey-frontend`
- **THEN** both MUST inherit the same validation timing and error presentation behavior
