## ADDED Requirements

### Requirement: Visibility control in secure entry fields
Every password field (secure entry) SHALL offer an optional reveal control using standard visibility icons.

#### Scenario: Toggle password visibility
- **WHEN** the user clicks on the eye icon in a password field
- **THEN** the password text toggles between masked characters and plain text
- **AND** the icon toggles between `visibility_off` and `visibility`
- **AND** focus and cursor position in the field are preserved

### Requirement: Support for assistive entry mechanisms
Authentication forms SHALL NOT block assistive entry mechanisms, such as text pasting or autofill by password managers.

#### Scenario: Paste password into field
- **WHEN** the user attempts to paste a previously copied password into the password field
- **THEN** the system allows pasting and the value is correctly reflected in the field

### Requirement: Prior visibility of password requirements
Password complexity requirements SHALL be visible to the user before they submit the registration or password change form.

#### Scenario: View password rules during registration
- **WHEN** the user accesses the professional registration screen
- **THEN** complexity rules (e.g., "mínimo 8 caracteres") are displayed as help text below the password field
- **AND** the visual state of the rules is updated as the user types (optional, but recommended)
