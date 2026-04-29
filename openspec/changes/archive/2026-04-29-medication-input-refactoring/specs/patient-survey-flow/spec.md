## MODIFIED Requirements

### Requirement: Demographic Information Screen
The system MUST allow the user to enter their demographic information. If this step is optional, the system MUST explain the benefits of providing data and allow skipping. The medication field MUST support multi-select with autocomplete against the ANVISA reference list.

#### Scenario: User submits demographic information
**Given** a user is on the demographic information screen
**When** the user fills in the form and clicks "Submit"
**Then** the system MUST send the survey response to the AI agent with the user's personal data and navigate to the report page.
**And** the medication field MUST contain a list of selected medication names.

#### Scenario: Optional demographics explanation
**Given** a user is on the demographic information screen
**When** the screen is optional
**Then** the system MUST display: "Estas informações opcionais ajudam em pesquisas estatísticas, mas você pode pular esta etapa se preferir."

#### Scenario: User enters multiple medications
- **WHEN** the user selects "Sim" for psychiatric medication use
- **THEN** the form MUST display a multi-select autocomplete field
- **AND** the user MUST be able to add multiple medications from the reference list or manually
- **AND** each selected medication MUST appear as a removable chip
