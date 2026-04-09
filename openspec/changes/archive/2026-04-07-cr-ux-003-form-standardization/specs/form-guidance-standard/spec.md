## ADDED Requirements

### Requirement: Forms SHALL reuse existing canonical summaries and groupings
Long forms or those distributed across sections SHALL reuse standardized shared components for grouping and summary, instead of creating a second parallel family of widgets.

#### Scenario: Submission with multiple errors
- **WHEN** the user clicks the "Enviar" button with 3 mandatory fields empty
- **THEN** the system displays the canonical form summary at the top of the page or section
- **AND** lists the fields that need attention.

### Requirement: Structured fields SHALL use shared formatters and normalization
Fields with structured formats (CPF, Telefone, CEP, Data) SHALL use shared formatters, constraints, and normalization in the design system.

#### Scenario: Filling in a date
- **WHEN** the user fills in a date field supported by the shared standard
- **THEN** the system guides and formats the input according to the `DD/MM/AAAA` standard
- **AND** validates the normalized value before submission

#### Scenario: Filling in CPF or CEP
- **WHEN** the user fills in a structured field such as CPF or CEP
- **THEN** the system restricts and normalizes the input according to the shared helper defined for that type
- **AND** the value sent to the backend remains in the format expected by the API

### Requirement: Brazilian Portuguese Localization (pt-BR)
All textual content presented to the user, including field labels, error messages, help texts, and warnings, SHALL be in Brazilian Portuguese strictly following grammatical rules, including the correct use of accentuation (e.g., "atenção", not "atencao").

#### Scenario: Checking accentuation in error messages
- **WHEN** an error message or warning is displayed to the user
- **THEN** the text SHALL contain all accents and special characters (cedilla, tilde) according to the standard pt-BR norm.

### Requirement: Mandatory Field Guidance
Mandatory fields SHALL be clearly marked with an asterisk (*) and related field groups SHALL have descriptive headers.

#### Scenario: Viewing a long form
- **WHEN** the user accesses a Builder section
- **THEN** all mandatory fields display the '*' symbol next to the label
- **AND** related fields (such as address) are grouped under the "Endereço" heading.

### Requirement: Long administrative forms SHALL preserve progress
Long administrative forms included in this change SHALL expose visible draft states and restore progress when this avoids relevant rework.

#### Scenario: Long editing interrupted in Builder
- **WHEN** the user changes a long administrative form and leaves the screen before final publication
- **THEN** the system preserves the draft according to the strategy defined for that flow
- **AND** displays a clear state such as "alterações não salvas" or "rascunho salvo"
