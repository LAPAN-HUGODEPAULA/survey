# Clinical Prompt Catalog Seed Handoff

## Purpose

This document prepares the reviewed documentation outputs for a later implementation change that will translate them into Mongo seed data.

The handoff source of truth is:

- [clinical-prompt-catalog-governance.md](/home/hugo/Documents/LAPAN/dev/survey/docs/clinical-prompt-catalog-governance.md)
- [clinical-prompt-catalog-bootstrap.md](/home/hugo/Documents/LAPAN/dev/survey/docs/bootstrap/clinical-prompt-catalog-bootstrap.md)
- [catalogo-de-prompts-clinicos-admin-ptbr.md](/home/hugo/Documents/LAPAN/dev/survey/docs/runbooks/catalogo-de-prompts-clinicos-admin-ptbr.md)
- [clinical-writer-prompt-catalog-deep-research-brief.md](/home/hugo/Documents/LAPAN/dev/survey/docs/research/clinical-writer-prompt-catalog-deep-research-brief.md)

## Seed Translation Targets

### `QuestionnairePrompts`

Starter records to prepare:

- `lapan_q7_clinical_logic`
- `chyps_v_br20_clinical_logic`
- `neurocheck_clinical_logic`

Required fields to carry into the implementation change:

- `promptKey`
- `name`
- `promptText`
- `surveyId` or equivalent questionnaire identifier
- `status`
- `version`
- source lineage metadata

### `PersonaSkills`

Starter records to prepare:

- `patient_condition_overview`
- `clinical_diagnostic_report`
- `clinical_referral_letter`
- `parental_guidance`
- `school_report`
- `neuropsychology_summary`
- `ophthalmology_screening_summary`

Required fields to carry forward:

- `personaSkillKey`
- `displayName`
- `instructions`
- `outputProfile`
- `status`
- `version`
- source lineage metadata

### `Output Profiles`

Implementation target:

- either a dedicated collection or a governed configuration structure, depending on the follow-on access-point implementation

Starter identifiers:

- `patient_condition_overview`
- `clinical_diagnostic_report`
- `clinical_referral_letter`
- `parental_guidance`
- `school_report`
- `neuropsychology_summary`
- `ophthalmology_screening_summary`

### `Agent Access Points`

Starter records to prepare:

- `survey_patient.thank_you.auto_analysis`
- `survey_patient.report.manual_generation`
- `survey_frontend.thank_you.auto_analysis`
- `survey_frontend.export.school_summary`
- `survey_frontend.export.referral_letter`

Required fields to carry forward:

- `accessPointKey`
- `displayName`
- target app or workflow metadata
- `promptKey`
- `personaSkillKey`
- `outputProfile`
- `status`
- `version`

## Publication Constraints

The later seed implementation must preserve these constraints:

- bootstrap content is not auto-published
- all translated records start from reviewed documentation, not directly from Google Drive
- version history must begin with a publish-aware model
- no PHI or secrets may enter seed fixtures
- referential integrity between prompt, persona, output profile, and access point must be validated before publication

## Recommended Translation Order

1. create questionnaire prompt drafts
2. create persona skill drafts
3. create output profile definitions
4. create access-point defaults
5. validate references and runtime precedence assumptions
6. publish only the approved initial active versions

## Questions Reserved For The Implementation Change

- whether `Output Profiles` become a dedicated collection or remain a governed identifier set
- whether seed fixtures should be Markdown-derived, JSON fixtures, or migration scripts
- whether starter access points should be published in the same migration as the catalog entries or in a separate migration after review
