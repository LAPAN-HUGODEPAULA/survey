## ADDED Requirements

### Requirement: The platform SHALL use a single validation cycle for structured forms
All migrated structured forms SHALL follow the same validation cycle to reduce inconsistency between apps and avoid premature hostile errors.

#### Scenario: Pristine field during first typing
- **WHEN** the user starts typing in a field not yet validated
- **THEN** the system SHALL NOT display a "campo obrigatório" error nor an incomplete format error during this first typing

#### Scenario: Touched field upon losing focus
- **WHEN** the user leaves a mandatory or structured field
- **THEN** the system SHALL validate this field on `blur`
- **AND** display the inline message if there is an error

#### Scenario: Form submission with failures
- **WHEN** the user attempts to continue or submit a form with invalid fields
- **THEN** the system SHALL validate all relevant fields at that moment
- **AND** display inline messages
- **AND** display a form summary when there are multiple failures or errors distributed across more than one section

#### Scenario: Efficient revalidation after visible error
- **WHEN** a field has already been marked as invalid and the user returns to edit it
- **THEN** the system MAY revalidate this field during subsequent edits
- **AND** SHALL NOT continuously revalidate fields that are still pristine or have never been exposed as invalid

### Requirement: Informative Error Messages
Field-level error messages SHALL be clear, objective, and indicate the necessary corrective action.

#### Scenario: Data format error
- **WHEN** the user inserts a date in an invalid format
- **THEN** the system displays "Use o formato DD/MM/AAAA." instead of "Valor inválido."

### Requirement: The validation standard SHALL live in the design system
The `pristine`, `touched`, `submitted`, and revalidation behaviors SHALL be centralized in `packages/design_system_flutter` to avoid divergent implementation per application.

#### Scenario: Two apps use the same shared field
- **WHEN** `survey-patient` and `survey-frontend` use the same shared field surface
- **THEN** both SHALL inherit the same validation timing and error presentation behavior
