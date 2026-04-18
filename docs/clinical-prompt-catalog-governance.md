# Clinical Prompt Catalog Governance

## Purpose

This document defines the canonical authoring model for the Clinical Writer prompt stack.
It exists to keep runtime behavior, builder administration, and future Mongo seed data aligned around the same taxonomy.

The target runtime stack is composed from four configuration layers:

1. `QuestionnairePrompts`
2. `PersonaSkills`
3. `Output Profiles`
4. `Agent Access Points`

This document is normative for authoring boundaries and publication workflow.
The bootstrap catalog remains a reviewed starter pack and is not a production publication by itself.

## Current State and Target State

### Current transitional state

- `clinical-writer-api` still supports legacy prompt resolution and Google Drive-backed prompt retrieval.
- Mongo-managed `QuestionnairePrompts` and `PersonaSkills` exist as the target source of truth.
- `outputProfile` is already used as a runtime selector, but it is not yet managed as a first-class catalog resource.
- explicit access-point administration is planned and documented, but not fully implemented yet.

### Target governed state

- questionnaire clinical reasoning lives only in `QuestionnairePrompts`
- audience and tone rules live only in `PersonaSkills`
- structural output expectations are defined by stable `Output Profiles`
- runtime entry points resolve the final stack through builder-managed `Agent Access Points`

## Prompt Stack Taxonomy

### 1. Questionnaire Prompt

Questionnaire prompts define domain interpretation logic for one instrument.

They must contain:

- questionnaire identity and intended input contract
- answer-to-score conversion rules
- axis, subtype, or domain mapping rules
- deterministic interpretation steps
- missing-data handling
- safe boundaries on claims
- facts that must be derived before narrative writing

They must not contain:

- patient-facing reassurance language
- clinician-facing style preferences
- school or referral phrasing
- report layout rules that belong to output profiles
- access-point routing decisions

Examples:

- `lapan_q7_clinical_logic`
- `chyps_v_br20_clinical_logic`
- `neurocheck_clinical_logic`

### 2. Persona Skill

Persona skills define voice, audience, terminology level, and narrative restrictions.

They must contain:

- intended audience
- tone and vocabulary level
- safe-claims boundaries
- emphasis and exclusions
- wording constraints for ambiguous or incomplete findings

They must not contain:

- questionnaire score formulas
- item-to-axis mappings
- survey-specific thresholds
- output schema definitions
- access-point resolution logic

Examples:

- `patient_condition_overview`
- `clinical_diagnostic_report`
- `clinical_referral_letter`
- `school_report`

### 3. Output Profile

Output profiles define structure and format expectations.
They are stable identifiers that allow multiple runtime surfaces to request the same response shape even when the persona wording evolves.

They should define:

- output contract type, such as JSON-only `ReportDocument`
- section ordering or field requirements
- formatting restrictions
- whether the output is intended for app rendering, export, or professional handoff

They must not contain:

- format specification
- document structure
- list of sections

Examples:

- `json schema`
- `parent_letter`
- `clinical_referral_letter`
- `school_report`

### 4. Agent Access Point

Agent access points bind a runtime entry point to the prompt stack that should be used there.

They should define:

- stable access-point key
- human-readable name
- target app or workflow metadata
- selected `promptKey`
- selected `personaSkillKey`
- selected `outputProfile`

They must not duplicate prompt text.
They are routing and default-binding records, not prompt content records.

Examples:

- `survey_patient.thank_you.auto_analysis`
- `survey_patient.report.manual_generation`
- `survey_frontend.thank_you.auto_analysis`
- `survey_frontend.export.school_summary`
- `survey_frontend.export.referral_letter`

## Authoring Boundary Guide

Use this decision table when adding or changing instructions.

| Instruction type | Correct home | Wrong home |
| --- | --- | --- |
| "Map 'Quase Sempre' to score 3" | Questionnaire Prompt | Persona Skill |
| "Use plain-language wording for caregivers" | Persona Skill | Questionnaire Prompt |
| "Return strict JSON matching `ReportDocument`" | Output Profile | Questionnaire Prompt |
| "Patient thank-you flow should use patient overview defaults" | Agent Access Point | Persona Skill |
| "Classify biological overload above 24 as urgent review" | Questionnaire Prompt | Output Profile |
| "Do not state a formal diagnosis from screener-only data" | Persona Skill and Questionnaire Prompt safety notes | Access Point |

## Runtime Composition Model

The intended runtime composition is:

1. Load questionnaire clinical logic from `QuestionnairePrompts`.
2. Load audience and style constraints from `PersonaSkills`.
3. Apply formatting and contract constraints from `Output Profiles`.
4. Resolve the effective stack through the selected access point.

The planned precedence order is:

1. explicit request override
2. access-point binding
3. survey defaults
4. approved legacy fallback

This precedence order matches the planned access-point model and should be used consistently in documentation and future implementation.

## Legacy Decomposition Blueprint

The legacy `Lapan7` JSON prompt in [prompts.py](/home/hugo/Documents/LAPAN/dev/survey/services/clinical-writer-api/clinical_writer_agent/prompts.py) mixes all layers together.

### Legacy content that belongs in the Questionnaire Prompt

- survey identity and accepted JSON input
- response-to-score conversion
- subtype mapping
- total score calculation
- qualitative burden interpretation
- treatment of non-visual sensory items

### Legacy content that belongs in the Persona Skill

- write in Brazilian Portuguese
- formal clinical tone
- conservative claims
- mention uncertainty when data is missing
- avoid meta-commentary

### Legacy content that belongs in the Output Profile

- produce a structured clinical report
- keep output suitable for charting and downstream app use
- respect section ordering
- avoid markdown artifacts that would break JSON-only consumers

## Active Version Lifecycle

Every prompt-catalog resource should support a two-step workflow.

### Step 1: Save

Save persists an editable draft.

Rules:

- draft changes are not runtime-active
- draft edits may be revised repeatedly without changing the active runtime version
- validation errors must be resolved before publication

### Step 2: Publish

Publish creates the active version used by runtime resolution.

Rules:

- publication must create an immutable versioned record
- version numbers increase only on publish, not on draft saves
- a published version must capture who published it and when
- if a resource is referenced by an access point, the active version is the one used at runtime

### Version increment rules

- content-only draft edit: no version change until publish
- first publication: `v1`
- subsequent publication with reviewed changes: increment to `v2`, `v3`, and so on
- rollback by publication: publish a new version that restores the approved prior content rather than mutating history in place

## Naming Rules

- use stable snake-case-like keys with lowercase words and underscores
- questionnaire prompts should end with `_clinical_logic` when they encode instrument interpretation
- persona skills should describe audience or communication function
- output profiles should remain stable across questionnaires when the structure is reusable
- access-point keys should follow `app.flow.action` naming

## Governance Rules

- keep one responsibility per catalog record
- do not copy prompt text between questionnaire prompts and persona skills
- do not place runtime-only routing assumptions inside prompt text
- keep bootstrap content clearly marked as reviewed starter material
- require human review before Mongo publication
- keep terminology aligned with the planned access-point model

## Privacy and Safety Rules

- never include PHI in prompt text, examples, notes, or seed packs
- never include secrets, tokens, credentials, or internal endpoints
- use synthetic examples and placeholders such as `PACIENTE_A` or `ID_EXEMPLO`
- never instruct the model to infer diagnoses beyond screener evidence
- represent uncertainty explicitly when data is missing, contradictory, or out of scope

## Seed Publication Readiness Checklist

- questionnaire prompt contains only instrument logic
- persona skill contains only audience and style rules
- output profile contains only structure and contract rules
- access-point bindings reference existing catalog keys
- no PHI or secrets appear in content or examples
- draft has clinical and product review notes
- publication intent is recorded separately from bootstrap status
