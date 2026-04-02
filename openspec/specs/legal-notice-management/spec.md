# legal-notice-management Specification

## Purpose
TBD - created by archiving change add-legal-notices. Update Purpose after archive.
## Requirements
### Requirement: Platform Terms of Use and Privacy Policy Access
The platform MUST expose the full `Termo de Uso e Política de Privacidade` from inside `survey-patient`, `survey-frontend`, `clinical-narrative`, and `survey-builder`.

#### Scenario: User opens the full legal terms from any app
- **WHEN** a user activates the legal footer link in any supported Survey app
- **THEN** the application MUST open the full `Termo de Uso e Política de Privacidade` inside the app in a screen, modal, or popup
- **AND** the content MUST remain available without redirecting the user to an external site

### Requirement: Canonical pt-BR Legal Content Rendering
The system MUST render the approved Brazilian Portuguese legal markdown documents with preserved heading, paragraph, emphasis, and list formatting.

#### Scenario: User views an in-app legal document
- **WHEN** the app renders `docs/legal/Termo-de-Uso-e-Política-de-Privacidade-ptbr.md` or `docs/legal/Aviso-Inicial-de-Uso-ptbr.md`
- **THEN** the viewer MUST show the full document content in Brazilian Portuguese
- **AND** the reading surface MUST be scrollable and suitable for long-form legal text on mobile and desktop layouts

### Requirement: Initial Notice Acknowledgement Control
Whenever the initial notice is required by an app flow, the system MUST present the notice content together with an acknowledgement checkbox and MUST keep the proceed action disabled until the checkbox is selected.

#### Scenario: User is blocked on a required initial notice
- **WHEN** an app flow requires the `Aviso Inicial de Uso`
- **THEN** the app MUST show the full notice text and the acknowledgement checkbox text derived from the approved document
- **AND** the primary action to continue MUST remain disabled until the user selects the checkbox

### Requirement: Application-Specific Enforcement Scope
The system MUST enforce the initial-notice gate only in the apps and flows that require agreement, while still exposing the full terms link everywhere.

#### Scenario: User opens survey-builder
- **WHEN** a user opens `survey-builder`
- **THEN** the app MUST show the shared footer link to the full `Termo de Uso e Política de Privacidade`
- **AND** the app MUST NOT require the initial-notice acknowledgement gate before normal use

