# Data Privacy, LGPD Governance & Legal Notices Specification

## Purpose
Consolidates LGPD compliance details, data subject rights (deletion, export), and legal terms/privacy policy presentation requirements.

## Requirements
### Requirement: Legal Basis Documentation
The system MUST document a valid LGPD legal basis for each processing activity involving personal or sensitive health data.

#### Scenario: Record legal basis for a processing activity
- **WHEN** a new processing activity is registered for patient data
- **THEN** the system MUST store the legal basis and purpose alongside the activity

### Requirement: Data Subject Rights Fulfillment
The system MUST support requests for data access, correction, portability, and deletion subject to legal constraints.

#### Scenario: Patient requests data access
- **WHEN** a patient submits a verified access request
- **THEN** the system MUST provide an export of the patient's data within the supported workflow

### Requirement: Privacy by Default and Minimization
The system MUST collect and expose only the minimum data required for the stated purpose and default to the most privacy-protective settings.

#### Scenario: Default data collection
- **WHEN** a patient or screener completes a data entry flow
- **THEN** optional fields MUST be clearly marked and excluded unless explicitly provided

#### Scenario: Trace AI processing without storing direct identifiers
- **WHEN** backend services record AI processing telemetry or request
  correlation metadata
- **THEN** they MUST prefer pseudonymized patient references over raw names
  or email addresses
- **AND** they MUST avoid persisting direct identifiers unless the workflow
  explicitly requires them

### Requirement: Sensitive logging minimization
Operational logs MUST avoid printing secrets, credentials, or full sensitive
payload bodies when a safer summary is sufficient.

#### Scenario: Upstream AI request fails
- **WHEN** an AI integration returns an error for a request that may contain
  patient content
- **THEN** the service MUST log the request identifier, status, and failure
  summary
- **AND** it MUST NOT log the full upstream response body by default

#### Scenario: Service bootstrap creates a temporary credential
- **WHEN** a service provisions an internal account or development credential
  at startup
- **THEN** production logs MUST NOT print the generated secret

### Requirement: Data Protection Impact Assessment
The system MUST maintain a DPIA record for high-risk processing involving sensitive health data or automated decision support.

#### Scenario: Introduce a high-risk processing change
- **WHEN** a feature introduces automated processing of sensitive health data
- **THEN** the system MUST record a DPIA entry with identified risks and mitigations

### Requirement: Prompt governance documentation MUST prohibit PHI and unsafe examples in authoring materials
Prompt-authoring documentation, bootstrap packs, and the builder admin runbook MUST instruct operators to avoid storing PHI, secrets, or unsafe sample data in prompts, examples, and seed materials.

#### Scenario: Admin consults the runbook before registering a prompt
- **WHEN** the admin reads the prompt-registration runbook
- **THEN** the guidance MUST explicitly prohibit copying real patient identifiers or unnecessary sensitive payloads into prompt content or examples
- **AND** it MUST provide safe alternatives such as synthetic examples and placeholder references

### Requirement: Builder audit data MUST follow LGPD-aligned minimization rules
Persistent audit records for `survey-builder` administration MUST store only the minimum data required for traceability, governance, and incident response. Audit entries MUST avoid PHI, raw secrets, and full prompt bodies unless a stricter governance requirement explicitly demands them.

#### Scenario: Admin edits a persona skill
- **WHEN** the system records an audit event for a persona-skill update
- **THEN** the event MUST store stable identifiers, action metadata, actor identity, timestamp, and outcome
- **AND** it MUST NOT persist unrelated patient data or the full persona instructions by default

#### Scenario: Admin action carries sensitive payload fields
- **WHEN** a builder-managed request contains secret material, patient references, or large prompt content
- **THEN** the audit layer MUST redact, omit, or summarize those fields according to the governance policy before persistence

### Requirement: Builder audit retention and access MUST be restricted
Builder audit data MUST be retained for a defined governance period and MUST be accessible only to authorized operational or compliance roles.

#### Scenario: Unauthorized user attempts to access builder audit records
- **WHEN** a user without explicit audit-review permission attempts to query or export builder audit data
- **THEN** the system MUST deny access
- **AND** it MUST record the attempt according to the platform audit policy

### Requirement: Configurable Data Retention Policy
The system MUST support configurable retention rules for sensitive data and apply them consistently across storage locations.

#### Scenario: Apply configured retention rule
- **WHEN** a retention rule is updated by an authorized administrator
- **THEN** the system MUST apply the rule to new and existing records according to the policy

### Requirement: Data Deletion and Anonymization Workflow
The system MUST support authorized deletion and anonymization workflows for personal data with auditability.

#### Scenario: Process a deletion request
- **WHEN** an authorized deletion request is approved
- **THEN** the system MUST delete or anonymize the data and record the action in audit logs

### Requirement: Consent Revocation Handling
The system MUST support consent revocation requests and restrict further processing where consent is the legal basis.

#### Scenario: Patient revokes consent
- **WHEN** a patient revokes consent for a processing activity
- **THEN** the system MUST stop processing under that consent and confirm the change

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
