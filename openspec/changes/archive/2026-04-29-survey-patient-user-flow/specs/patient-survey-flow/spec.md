## MODIFIED Requirements

### Requirement: Initial Notice Gate
The system MUST require acknowledgement of the `Aviso Inicial de Uso` before the public patient welcome screen becomes available. After acknowledgement, the system MUST navigate to the patient identification screen instead of directly to the welcome screen.

#### Scenario: Patient opens the Survey Patient app
- **WHEN** a user opens `survey-patient`
- **THEN** the application MUST show the initial-notice screen with the full notice content and acknowledgement checkbox
- **AND** the proceed button MUST remain disabled until the user checks the acknowledgement checkbox
- **AND** after acknowledgement the application MUST navigate to the patient identification screen

#### Scenario: Patient completes identification
- **WHEN** the patient fills identification fields and continues
- **THEN** the application MUST navigate to the welcome screen

## MODIFIED Requirements

### Requirement: Thank You Screen
The system MUST display a thank you screen that follows a three-step handoff sequence. The page MUST include an "Converse com o especialista" section with an external Irlen Syndrome GPT link.

#### Scenario: User views the specialist link on thank-you page
- **WHEN** the user is on the thank-you page
- **THEN** a "Converse com o especialista" section MUST be visible with the Irlen Syndrome GPT link

## MODIFIED Requirements

### Requirement: Demographic Information Screen
The system MUST allow the user to enter additional demographic information. All fields on this page are optional. The page MUST NOT include patient identification fields (name, email, birth date) or a skip section.

#### Scenario: User views demographics page
- **WHEN** the user navigates to the demographics page
- **THEN** the page MUST show only the "Dados complementares" section
- **AND** the page MUST NOT show the "Identificação" section
- **AND** the page MUST NOT show the "Adicionar informações é opcional" skip section

#### Scenario: User submits without filling optional fields
- **WHEN** the user taps the continue button without filling any optional fields
- **THEN** the system MUST proceed to the report page without validation errors
