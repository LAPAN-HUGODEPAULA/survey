# Clinical Writer Prompt Catalog Deep Research Brief

## Objective

This document is the working brief for refining the LAPAN Clinical Writer prompt stack before seeding MongoDB.
It decomposes the current prompt inventory, highlights quality issues, and proposes a target catalog that can later be reviewed and then persisted as:

- `QuestionnairePrompts`
- `PersonaSkills`
- `outputProfile` mappings
- agent access-point defaults

## Current Runtime Situation

- The current `clinical_writer_agent` deployment is configured with `PROMPT_PROVIDER=google_drive`.
- MongoDB currently has no seed data in `QuestionnairePrompts` or `PersonaSkills`.
- The current runtime failure seen in `survey-patient` is not quota-related.
- The failure occurs during prompt resolution in the Google Drive path, which makes Google Drive a runtime-critical dependency.

## Current Google Drive Prompt Inventory

### `survey7`

Observed behavior:
- Portuguese prompt for `Lapan Q7`
- expects JSON input with patient data and 7 answers
- converts qualitative responses to scores
- uses weighted scale `0, 1, 2, 5`
- distinguishes visual subtypes
- aims for a more clinically descriptive report and appears closer to a patient-oriented overview than the narrower specialty variants

Key strengths:
- includes explicit scoring rules
- includes subtype reasoning
- includes clinical intent

Key issues:
- bundles questionnaire logic, scoring logic, output format, and presentation style in one document
- hardcodes the final output behavior instead of separating domain and persona

### `survey7_school`

Observed behavior:
- despite the key suggesting an education-facing audience, the visible text is a medical report prompt
- uses weighted scale `0, 1, 2, 3`
- appears structurally identical to the neuro and ophthalm variants in the sampled portion

Key issues:
- the key and visible content are misaligned
- the prompt does not appear school-facing
- likely duplicated content under different names

### `survey7_neuro`

Observed behavior:
- visible portion is materially identical to `survey7_school`
- appears to be another copy of a generic medical report prompt

Key issues:
- unclear differentiation from other variants
- audience specialization is not visible in the prompt body

### `survey7_ophthalm`

Observed behavior:
- visible portion is materially identical to `survey7_school` and `survey7_neuro`
- appears to be another copy of the same medical report prompt

Key issues:
- unclear ophthalmology-specific behavior
- duplication suggests key proliferation without real prompt specialization

### `full_intake`

Observed behavior:
- identifies itself as a CHYPS-V-Br 20 prompt
- output target is a structured clinical report
- visible section still references Lapan Q7 in the input description and scoring notes

Key issues:
- internal inconsistency between questionnaire identity and described input
- signs of copy-paste drift
- unsafe as a canonical source without revision

### `default`

Observed behavior:
- direct ad hoc retrieval failed once with a Google Drive internal error

Key issue:
- reinforces that the platform should not depend on this source for runtime-critical resolution

## Main Structural Problems In The Current Catalog

1. Questionnaire logic and persona style are mixed in single prompts.
2. Prompt keys imply audience specialization that is not clearly expressed in content.
3. At least one prompt shows survey identity drift.
4. Scoring systems are embedded in free text instead of living in a clearly governed questionnaire layer.
5. The runtime source is operationally fragile.

## Proposed Target Prompt Architecture

### Layer 1: Questionnaire clinical logic

Each questionnaire prompt should encode only:

- instrument identity
- accepted input contract
- answer-to-score conversion
- subtype grouping
- clinical reasoning rules
- missing-data behavior
- output facts that must be derived before narrative writing

Recommended starter questionnaire prompts:

1. `lapan_q7_clinical_logic`
   - clinical interpretation for the LAPAN Q7 visual hypersensitivity screener
   - keep the weighted `0, 1, 2, 5` scoring only if clinically justified after review

2. `chyps_v_br20_clinical_logic`
   - clinical interpretation for CHYPS-V-Br 20
   - must remove any leftover Lapan Q7 references

3. `neurocheck_clinical_logic`
   - clinical interpretation for Neurocheck
   - must be authored explicitly; no trustworthy Google Drive variant was identified during this inspection

### Layer 2: Persona skills

Each persona skill should encode only:

- target audience
- tone
- terminology level
- safe claims boundaries
- formatting expectations
- emphasis and exclusions

Recommended starter persona skills:

1. `patient_condition_overview`
   - audience: patient and family
   - tone: plain-language, careful, reassuring without overpromising
   - goal: explain findings and next steps

2. `clinical_diagnostic_report`
   - audience: clinician
   - tone: formal, technical, concise
   - goal: document clinically relevant interpretation and reasoning

3. `clinical_referral_letter`
   - audience: receiving specialist
   - tone: referral-ready, focused on symptoms, findings, and rationale

4. `parental_guidance`
   - audience: caregiver
   - tone: practical, understandable, action-oriented

5. `school_report`
   - audience: educators
   - tone: non-diagnostic, function-focused, accommodation-oriented

6. `neuropsychology_summary`
   - audience: neuropsychology workflow
   - tone: cognitive and behavioral framing, careful with differential claims

7. `ophthalmology_screening_summary`
   - audience: eye-care professional
   - tone: vision-specific, symptom-pattern oriented, referral-safe

## Recommended Starter Output Profiles

Output profiles should remain stable identifiers that map to personas and formatting expectations.

Recommended starter profiles:

- `patient_condition_overview`
- `clinical_diagnostic_report`
- `clinical_referral_letter`
- `parental_guidance`
- `school_report`
- `neuropsychology_summary`
- `ophthalmology_screening_summary`

## Proposed Initial Agent Access Points

These access points should become configurable from `survey-builder`.

| Access point key | Intended app surface | Starter default |
| --- | --- | --- |
| `survey_patient.thank_you.auto_analysis` | automatic report after patient submission | `patient_condition_overview` |
| `survey_patient.report.manual_generation` | explicit report generation in patient flow | `clinical_diagnostic_report` |
| `survey_frontend.thank_you.auto_analysis` | automatic screener-facing result after professional submission | `clinical_diagnostic_report` |
| `survey_frontend.export.school_summary` | future school-facing export | `school_report` |
| `survey_frontend.export.referral_letter` | future clinician handoff export | `clinical_referral_letter` |

## Deep Research Questions

Use these questions in Deep Research before any Mongo seed is finalized.

### Questionnaire prompt design

1. What is the best structure for a questionnaire prompt that must perform deterministic score extraction before narrative generation?
2. How should answer-to-score mappings be expressed to minimize hallucination and arithmetic drift?
3. What prompt pattern best separates clinical interpretation rules from output wording rules?

### Persona design

4. What prompt ingredients best distinguish patient-facing, clinician-facing, school-facing, and referral-facing outputs without duplicating questionnaire logic?
5. How should a persona skill specify tone restrictions while remaining reusable across questionnaires?

### Safety and compliance

6. What prompt constraints best prevent diagnostic overreach when the source instrument is only a screener?
7. How should missing or contradictory data be surfaced in a safe, audit-friendly way?
8. What are the best prompt patterns to avoid leaking PHI into logs, examples, or intermediate reasoning artifacts?

### Output contract quality

9. What JSON-first prompting patterns best preserve strict schema validity for clinical report generation?
10. How should prompt instructions distinguish required facts, derived facts, and optional narrative interpretation?

## Proposed Seed Pack After Review

After the Deep Research pass, create:

- 3 questionnaire prompts
- 6 to 7 persona skills
- 6 to 7 output profiles aligned with persona skills
- 5 initial access-point records
- 3 survey-to-default mappings

## Bootstrap Draft Catalog

This is the recommended starting catalog for review. It is intentionally more structured than the current Google Drive inventory and is meant to be challenged before publication.

### Questionnaire prompt drafts

#### `lapan_q7_clinical_logic`

- survey: `lapan_q7`
- purpose: transform LAPAN Q7 answers into a structured interpretation of visual hypersensitivity burden
- must include:
  - exact answer mapping
  - total score calculation
  - subtype grouping
  - handling for non-visual context items
  - rules for classifying intensity without pretending there are validated normative cutoffs if they do not exist
- must avoid:
  - audience-specific tone rules
  - school guidance
  - referral phrasing
  - patient-friendly reassurance language

#### `chyps_v_br20_clinical_logic`

- survey: `chyps_v_br20`
- purpose: interpret the CHYPS-V-Br 20 visual hypersensitivity questionnaire
- must include:
  - corrected survey identity everywhere
  - item-to-subtype grouping
  - explicit total and subtype score rules
  - caution against copying Lapan Q7 wording or thresholds
- must avoid:
  - any mention of Lapan Q7 unless as explicit comparative context approved by the team

#### `neurocheck_clinical_logic`

- survey: `neurocheck`
- purpose: interpret the Neurocheck questionnaire according to its own domain model
- must include:
  - explicit item map
  - domain-specific scoring logic
  - clinical interpretation boundaries
- must avoid:
  - inheriting visual hypersensitivity logic from unrelated instruments

### Persona skill drafts

#### `patient_condition_overview`

- audience: patient or family
- emphasis:
  - plain language
  - symptom explanation
  - next-step orientation
  - emotional clarity without false reassurance
- restrictions:
  - do not present screening results as definitive diagnosis
  - define technical terms when necessary

#### `clinical_diagnostic_report`

- audience: clinician
- emphasis:
  - formal tone
  - precise clinical vocabulary
  - concise interpretation
  - explicit uncertainty handling
- restrictions:
  - do not invent history or exam findings
  - do not overstate causality

#### `clinical_referral_letter`

- audience: receiving specialist
- emphasis:
  - reason for referral
  - relevant symptoms and score patterns
  - summary of concern and suggested follow-up
- restrictions:
  - do not repeat full questionnaire analysis when a concise handoff is enough

#### `parental_guidance`

- audience: caregiver
- emphasis:
  - practical daily-life implications
  - environment and routine adjustments
  - concrete next steps
- restrictions:
  - avoid excessive technical language
  - avoid unsupported treatment recommendations

#### `school_report`

- audience: school staff
- emphasis:
  - function in classroom and study settings
  - accommodations and observation points
  - non-stigmatizing language
- restrictions:
  - avoid diagnostic certainty
  - avoid medical jargon when simpler wording is available

#### `neuropsychology_summary`

- audience: neuropsychology-oriented professional workflow
- emphasis:
  - attentional load
  - sensory-cognitive interaction
  - fatigue and performance framing
- restrictions:
  - do not claim deficits not supported by questionnaire evidence

#### `ophthalmology_screening_summary`

- audience: ophthalmology or vision-care workflow
- emphasis:
  - light sensitivity
  - visual triggers
  - symptom patterns relevant to eye-care triage
- restrictions:
  - do not infer ocular pathology from screening answers alone

### Output profile draft expectations

Each output profile should define:

- intended audience
- primary report title style
- preferred section list
- terminology density
- explanation depth
- recommendation style

Recommended section expectations:

#### `patient_condition_overview`

- overview
- main findings
- symptom interpretation
- practical next steps

#### `clinical_diagnostic_report`

- identification
- instrument and method
- quantitative analysis
- clinical interpretation
- diagnostic impression or diagnostic considerations
- recommendations

#### `clinical_referral_letter`

- referral reason
- key findings
- supporting evidence
- requested follow-up

#### `parental_guidance`

- what the responses suggest
- what this may look like in daily life
- what caregivers can observe
- practical support suggestions

#### `school_report`

- classroom-relevant findings
- functional impacts
- accommodation suggestions
- communication notes for school team

#### `neuropsychology_summary`

- symptom pattern summary
- cognitive-load interpretation
- fatigue and overstimulation considerations
- follow-up guidance

#### `ophthalmology_screening_summary`

- visual trigger summary
- symptom context
- eye-care referral considerations
- follow-up recommendations

## Recommendation

Do not seed MongoDB directly from the current Google Drive prompts.

Instead:

1. use the current prompts as raw source material
2. rewrite them into separated questionnaire and persona components
3. validate them through Deep Research
4. only then publish them through `survey-builder` and seed MongoDB
