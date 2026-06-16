# Screener & Patient Survey Prompt Management Specification

## Purpose
Consolidates configuration rules, versioning, storage, and runtime resolution of questionnaire prompts, persona skills, and agent access points.

## Requirements
### Requirement: The system MUST provide a MongoDB-backed QuestionnairePrompts catalog for questionnaire-specific clinical logic.

The system MUST store questionnaire clinical instructions in a dedicated `QuestionnairePrompts` collection. These documents MUST represent only the clinical logic that belongs to a questionnaire and MUST remain independent from output-profile style concerns.

#### Scenario: Create a questionnaire prompt
- **Given** an administrator is configuring AI behavior for a questionnaire
- **When** they create a `QuestionnairePrompts` document with a human-readable name, a stable questionnaire prompt key, and questionnaire-specific instructions
- **Then** the system MUST persist that document in MongoDB
- **And** it MUST make that questionnaire prompt available for runtime resolution

#### Scenario: List questionnaire prompts
- **Given** questionnaire prompts exist in the system
- **When** an administrative client requests the questionnaire prompt catalog
- **Then** the system MUST return the stored questionnaire prompt definitions
- **And** it MUST not require persona or output-profile metadata in that catalog response

### Requirement: Questionnaire prompt definitions MUST use stable keys and remain free of persona-specific styling.

Each `QuestionnairePrompts` document MUST have a unique stable key suitable for runtime lookup, a non-empty name, and non-empty clinical instructions. The system MUST reject attempts to encode persona-only concerns inside the questionnaire prompt definition when those concerns belong to `PersonaSkills`.

#### Scenario: Reject a duplicate questionnaire prompt key
- **Given** a questionnaire prompt already exists with a given stable key
- **When** another questionnaire prompt is created or updated to use the same key
- **Then** the system MUST reject the request with a validation error

#### Scenario: Reject an empty questionnaire prompt
- **Given** an administrator submits a questionnaire prompt definition
- **When** the name or clinical instructions are blank
- **Then** the system MUST reject the request with a validation error

### Requirement: The system MUST prevent deleting a prompt that is still associated with a survey.

Deleting a prompt that is still referenced by a questionnaire would create a broken report-generation path and MUST be blocked until the association is removed.

#### Scenario: Attempt to delete a prompt still used by a questionnaire
- **Given** a reusable prompt is associated with at least one survey
- **When** an administrator attempts to delete that prompt
- **Then** the system MUST reject the deletion
- **AND** it MUST explain that the prompt is still in use by a questionnaire

### Requirement: Questionnaire prompt governance MUST define authoring boundaries and starter records
The questionnaire prompt catalog documentation MUST define what belongs inside questionnaire prompts, what must stay out of them, and which starter questionnaire prompts are proposed for the initial bootstrap catalog.

#### Scenario: Admin reviews a questionnaire prompt candidate
- **WHEN** an administrator evaluates a questionnaire prompt draft
- **THEN** the governance documentation MUST state the expected structure, naming rules, and prohibited persona-only content
- **AND** it MUST identify whether the draft aligns with one of the documented starter prompt candidates

### Requirement: Questionnaire prompts MUST be referenceable from access-point configuration
The questionnaire prompt catalog MUST support stable runtime references from access-point definitions managed in `survey-builder`.

#### Scenario: Prompt appears in access-point configuration
- **WHEN** an administrator configures an agent access point in `survey-builder`
- **THEN** the questionnaire prompt catalog MUST expose prompt entries by stable key and display name
- **AND** the system MUST preserve referential integrity between the access point and the selected prompt

#### Scenario: Admin attempts to delete a prompt bound to an access point
- **WHEN** an administrator tries to delete a questionnaire prompt that is currently referenced by an agent access point
- **THEN** the system MUST reject the deletion
- **AND** it MUST explain that the prompt is still in use by runtime access-point configuration

### Requirement: The system MUST provide a MongoDB-backed PersonaSkills catalog for output-profile style and restrictions.

The system MUST store output-profile persona definitions in a dedicated `PersonaSkills` collection. Each persona skill MUST describe the tone, audience expectations, style constraints, or safety restrictions for one runtime output profile.

#### Scenario: Create a persona skill for school reports
- **Given** an administrator is configuring the tone for the school report output profile
- **When** they create a `PersonaSkills` document with a stable persona key, an output-profile binding, and persona instructions
- **Then** the system MUST persist the persona skill in MongoDB
- **And** it MUST make that persona skill available for runtime resolution

#### Scenario: List persona skills
- **Given** persona skills exist in the system
- **When** an administrative client requests the persona skill catalog
- **Then** the system MUST return the stored persona skill definitions
- **And** each definition MUST remain independent from questionnaire-specific clinical logic

### Requirement: Persona skills MUST be uniquely identifiable and editable as operational configuration.

Each `PersonaSkills` document MUST have a unique stable key, a unique declared output profile, and non-empty persona instructions. Editing a persona skill MUST be treated as an operational configuration change rather than a code change, and administrators MUST be able to remove obsolete persona skills from the catalog.

#### Scenario: Reject a duplicate persona skill key
- **Given** a persona skill already exists with a given stable key
- **When** another persona skill is created or updated to use the same key
- **Then** the system MUST reject the request with a validation error

#### Scenario: Reject a duplicate output profile
- **Given** a persona skill already exists for an output profile
- **When** another persona skill is created or updated to use that same `outputProfile`
- **Then** the system MUST reject the request with a validation error

#### Scenario: Update the school report tone
- **Given** a persona skill exists for the school report output profile
- **When** a physician edits its persona instructions in the operational catalog
- **Then** the system MUST persist the updated persona skill version
- **And** the updated document MUST be available for the next eligible runtime request

#### Scenario: Delete an obsolete persona skill
- **Given** a persona skill exists in the catalog
- **When** an administrator deletes that persona skill through the operational management interface
- **Then** the system MUST remove it from the catalog

### Requirement: Persona-skill governance MUST define authoring boundaries and starter records
The persona-skill documentation MUST define what belongs inside persona skills, how they relate to output profiles, and which starter persona skills are proposed for the initial bootstrap catalog.

#### Scenario: Admin reviews a persona skill draft
- **WHEN** an administrator evaluates a persona-skill candidate
- **THEN** the governance documentation MUST explain the expected output-style responsibilities and prohibited questionnaire-specific clinical logic
- **AND** it MUST show how the candidate maps to a documented starter persona skill or output profile

### Requirement: Persona skills MUST be referenceable from access-point configuration
The persona-skill catalog MUST support stable runtime references from access-point definitions and MUST preserve referential integrity for those bindings.

#### Scenario: Persona skill is selected for an access point
- **WHEN** an administrator selects a persona skill while configuring an access point
- **THEN** the system MUST store the selected `personaSkillKey` as part of that access-point definition
- **AND** the saved binding MUST be available for runtime resolution on the next eligible request

#### Scenario: Admin attempts to delete a bound persona skill
- **WHEN** an administrator tries to delete a persona skill that is referenced by an access point
- **THEN** the system MUST reject the deletion
- **AND** it MUST explain that the persona skill is still required by runtime configuration

### Requirement: Agent Access Points MUST resolve provider and model
The system SHALL support explicit binding of an access point to an ordered list of AI agent route entries. Each route entry SHALL reference an AI agent catalog record and MAY override the model and request parameters for that access point.

#### Scenario: Access point configures ordered agent route
- **WHEN** an access point has `aiConfig.agentRefs` assigned in the Builder
- **THEN** the backend MUST prioritize the first enabled route entry as the primary runtime model
- **AND** it MUST propagate the ordered enabled route entries to the Clinical Writer API

#### Scenario: Access point configures fallbacks
- **WHEN** an access point has multiple enabled `agentRefs`
- **THEN** the runtime MUST attempt the route entries in stored order
- **AND** it MUST treat entries after the first enabled entry as fallback agents

#### Scenario: Access point uses legacy model binding during migration
- **WHEN** an access point has legacy `primaryProvider` and `primaryModel` fields but does not have `agentRefs`
- **THEN** the backend MUST continue resolving the legacy fields for backward-compatible execution
- **AND** new Builder writes MUST persist `agentRefs` instead of legacy provider/model pairs

### Requirement: Agent Access Point contracts MUST use only aiConfig for AI settings
The platform MUST use `aiConfig` as the only access-point AI settings container and MUST store ordered agent routing inside that container.

#### Scenario: Admin saves access point AI settings
- **WHEN** an admin creates or updates AI settings for an access point
- **THEN** the payload MUST use `aiConfig.agentRefs` as the route definition
- **AND** retired flat fields (`aiProvider`, `glmModel`, `geminiModel`) MUST NOT be used

#### Scenario: Access point has no route entries
- **WHEN** an access point is saved without enabled `aiConfig.agentRefs`
- **THEN** the backend MUST reject the access point AI configuration unless a legacy configuration is being read during migration
- **AND** the runtime MUST NOT invent a global model selection

### Requirement: Survey-based report flows MUST resolve questionnaire logic and output persona separately.

Survey-based report generation MUST treat questionnaire clinical logic and output-profile persona as separate runtime inputs. The questionnaire determines the `QuestionnairePrompt`, while the report flow determines the `PersonaSkill` for the desired output profile.

When a survey stores default `personaSkillKey` or `outputProfile` configuration, the system MUST use those survey defaults before applying legacy hardcoded persona fallback rules.

#### Scenario: Generate a school report from a questionnaire response
- **Given** a questionnaire response has been submitted successfully
- **And** the questionnaire has a configured `QuestionnairePrompt`
- **And** the report flow selects the school report output profile
- **When** the AI generation flow starts
- **Then** the system MUST resolve the questionnaire prompt separately from the school report persona skill
- **And** it MUST avoid relying on a single hardcoded prompt to supply both concerns

#### Scenario: No explicit persona override is supplied but the survey has defaults
- **Given** a survey-derived request has no request-level `personaSkillKey` or `outputProfile`
- **And** the survey stores default persona configuration
- **When** report generation starts
- **Then** the system MUST use the survey defaults before consulting legacy hardcoded mappings

### Requirement: Survey report generation MUST propagate questionnaire prompt identity and persona skill identity end to end.

The survey backend and worker MUST carry the questionnaire prompt identifier and the persona skill identifier through AI enrichment so the generated report reflects both the clinical logic of the questionnaire and the stylistic constraints of the selected output profile.

Request-level `personaSkillKey` or `outputProfile` values MUST override survey defaults. When neither request-level nor survey-level persona settings are present, the system MUST preserve current fallback behavior. When a survey-level `personaSkillKey` is configured but no longer resolves to a known persona skill, the system MUST return a clear configuration error instead of silently falling back.

#### Scenario: Submit a survey response for school-report generation
- **Given** the survey flow has resolved both a questionnaire prompt and a school-report persona skill
- **When** the system submits the request for AI enrichment
- **Then** it MUST send both identifiers through the backend and worker path
- **And** the Clinical Writer MUST use those identifiers to resolve the final runtime prompt

#### Scenario: Request-level persona settings override survey defaults
- **Given** a survey stores default `personaSkillKey` or `outputProfile`
- **And** the incoming request explicitly provides `personaSkillKey` or `outputProfile`
- **When** report generation starts
- **Then** the system MUST use the request-level values instead of the survey defaults

#### Scenario: No explicit persona skill is supplied anywhere
- **Given** a survey-derived request has a questionnaire prompt
- **And** neither the request nor the survey provides persona configuration
- **When** report generation starts
- **Then** the system MUST use the default persona skill configured for that report flow or return a clear configuration error
- **And** it MUST NOT silently collapse persona selection back into hardcoded LangGraph prompt text

#### Scenario: Survey references a deleted persona skill
- **Given** a survey stores a `personaSkillKey` that no longer exists in the persona catalog
- **When** report generation starts without a request-level persona override
- **Then** the system MUST return a clear configuration error
- **And** it MUST NOT silently fall back to a different persona

### Requirement: System MUST provide a patient_condition_report persona skill
The backend SHALL seed a persona skill with key `patient_condition_report`, name "Patient Condition Report", output profile `patient_condition_report`, and instructions focused on generating a detailed, structured clinical report.

#### Scenario: Persona is available for access point binding
- **WHEN** a survey-builder admin creates or edits an access point
- **THEN** the persona dropdown MUST include "Patient Condition Report · patient_condition_report"

#### Scenario: Persona outputProfile matches access point binding
- **WHEN** an access point is created with `personaSkillKey: "patient_condition_report"` and `outputProfile: "patient_condition_report"`
- **THEN** the backend MUST accept the binding without validation error

### Requirement: Persona seed MUST include distinct instructions from patient_condition_overview
The `patient_condition_report` persona instructions SHALL focus on comprehensive, structured clinical analysis with clear sections (diagnostic impressions, functional impact, recommendations), distinct from the concise `patient_condition_overview` summary.

#### Scenario: Report persona produces structured output
- **WHEN** the clinical writer processes a survey response using the `patient_condition_report` persona
- **THEN** the output MUST include structured sections suitable for a clinical report
- **AND** the output style MUST differ from the concise `patient_condition_overview` summary

### Requirement: The platform MUST document the Clinical Writer prompt stack taxonomy
The platform MUST maintain detailed documentation that explains the role, required fields, and authoring boundaries for questionnaire prompts, persona skills, output profiles, and agent access points.

#### Scenario: Admin needs to understand where a new instruction belongs
- **WHEN** an administrator or developer needs to add or revise Clinical Writer behavior
- **THEN** the documentation MUST explain whether the instruction belongs in a questionnaire prompt, persona skill, output profile, or access-point configuration
- **AND** it MUST provide examples of correct decomposition boundaries

### Requirement: The platform MUST provide a Portuguese admin runbook for prompt operations
The system documentation set MUST include a Portuguese runbook that explains how the designated admin registers, reviews, updates, and validates prompt-catalog records in `survey-builder`.

#### Scenario: Admin prepares to register a new prompt
- **WHEN** the builder administrator needs to create or revise a prompt-related catalog entry
- **THEN** the Portuguese runbook MUST describe the required inputs, review checklist, and validation steps
- **AND** it MUST explain how to avoid PHI, unsafe examples, and catalog-boundary mistakes during registration

### Requirement: The platform MUST maintain a bootstrap prompt catalog plan
The system MUST maintain a documented bootstrap pack that decomposes the current prompt inventory into starter questionnaire prompts, persona skills, output profiles, and access-point defaults suitable for later publication.

#### Scenario: Team reviews the initial prompt inventory
- **WHEN** the team evaluates the documented bootstrap catalog
- **THEN** the material MUST identify each proposed starter record, its intended purpose, and its source prompt lineage
- **AND** it MUST clearly distinguish reviewed starter content from unpublished draft material

### Requirement: System MUST provide a detailed report access point for survey-patient
The backend SHALL seed an access point with key `survey_patient.report.detailed_analysis` that uses the default "Triagem de pacientes" prompt and `patient_condition_report` persona.

#### Scenario: Access point is seeded and available
- **WHEN** the seed script runs
- **THEN** the `agent_access_points` collection MUST contain a document with `accessPointKey: "survey_patient.report.detailed_analysis"`
- **AND** `promptKey` MUST be `"survey7"`
- **AND** `personaSkillKey` MUST be `"patient_condition_report"`
- **AND** `outputProfile` MUST be `"patient_condition_report"`

#### Scenario: Access point is configurable in survey-builder
- **WHEN** an admin opens the access point form in survey-builder
- **THEN** `RuntimeAccessPointCatalog` MUST include `survey_patient.report.detailed_analysis` as a configurable entry
- **AND** the admin MUST be able to select it from the injection point dropdown

### Requirement: survey-builder MUST handle existing access points gracefully
When a user tries to create an access point that already exists (DuplicateKeyError / 409), the survey-builder SHALL detect the existing record and switch to update mode instead of failing.

#### Scenario: User creates an already-seeded access point
- **WHEN** the user selects a configurable injection point that already exists in the database and submits
- **THEN** the survey-builder MUST check if the access point exists before POST
- **AND** if it exists, the survey-builder MUST use PUT to update instead of POST
- **AND** the form MUST NOT show a 409 error to the user
