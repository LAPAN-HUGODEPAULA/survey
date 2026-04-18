# Clinical Prompt Catalog Bootstrap Pack

## Status

This bootstrap pack is a reviewed starting point for catalog design.
It is not a final clinical approval and must not be treated as published Mongo seed data without an explicit follow-on review and publication step.

## Source Lineage

This bootstrap pack is derived from:

- the legacy `JsonPrompts.MEDICAL_RECORD_PROMPT` in [prompts.py](/home/hugo/Documents/LAPAN/dev/survey/services/clinical-writer-api/clinical_writer_agent/prompts.py)
- the current runtime composition behavior in [prompt_registry.py](/home/hugo/Documents/LAPAN/dev/survey/services/clinical-writer-api/clinical_writer_agent/prompt_registry.py)
- the `NeuroCheck` survey definition in [neurocheck.json](/home/hugo/Documents/LAPAN/dev/survey/apps/survey-patient/assets/surveys/neurocheck.json)
- the current research notes in [clinical-writer-prompt-catalog-deep-research-brief.md](/home/hugo/Documents/LAPAN/dev/survey/docs/research/clinical-writer-prompt-catalog-deep-research-brief.md)

## Legacy `Lapan7` Decomposition

### Proposed Questionnaire Prompt

#### `lapan_q7_clinical_logic`

Purpose:
- interpret LAPAN Q7 screener results for visual hypersensitivity burden

Input expectations:
- survey identity `lapan_q7`
- patient metadata when available
- answers for items `1` to `7`

Clinical logic responsibilities:
- map categorical answers to `0, 1, 2, 3`
- compute total score across the seven items
- derive subtype observations for:
  - brightness
  - movement or strobing
  - intense visual environments
- note that pattern sensitivity is not directly measured in the current questionnaire
- mention non-visual sensory items as associated context without adding them to visual subtype scores
- classify burden qualitatively without claiming validated normative cutoffs unless later evidence is added

Must exclude:
- patient reassurance style
- referral wording
- school-oriented guidance
- final section ordering

#### Draft domain prompt blueprint

```text
Instrument: LAPAN Q7 visual hypersensitivity screener.
Task: convert categorical answers into deterministic scores, calculate total burden, describe subtype-specific findings, and state uncertainty when the questionnaire does not directly support a stronger claim.
Scoring: Quase Nunca=0, Ocasionalmente=1, Frequentemente=2, Quase Sempre=3.
Subtype mapping:
- Brightness: items 1 and 6
- Movement/Strobing: items 4 and 6
- Intense Visual Environments: items 2 and 7
- Non-visual associated context only: items 3 and 5
Interpretation rule: use qualitative burden statements grounded in the answer distribution; do not claim diagnostic confirmation from screener-only data.
```

### Proposed Persona Skill

#### `clinical_diagnostic_report`

Purpose:
- render a formal clinician-facing report in pt-BR

Responsibilities:
- formal medical tone
- concise synthesis
- careful uncertainty language
- no decorative wording
- no diagnostic overreach

Must exclude:
- score arithmetic
- subtype rules
- survey-specific thresholds

#### Draft persona blueprint

```text
Audience: clinician.
Language: pt-BR.
Style: formal, concise, technically precise.
Safety: describe findings as screener-based, identify uncertainty explicitly, avoid definitive diagnosis unless the input already contains clinician-confirmed information.
```

### Proposed Output Profile

#### `clinical_diagnostic_report`

Purpose:
- define the structural output expectations for a clinician-facing report

Responsibilities:
- stable output identifier
- chart-friendly section ordering
- compatibility with downstream structured rendering

Must exclude:
- questionnaire-specific scoring
- audience tone rules

## `NeuroCheck` Questionnaire Draft

### Proposed Questionnaire Prompt

#### `neurocheck_clinical_logic`

Purpose:
- interpret the `NeuroCheck` screener as a four-axis sensory and biological overload profile

Instrument observations from the current survey asset:

- 12 questions with categorical answers `Confortável`, `Razoável`, `Desconfortável`
- four intended axes named in the survey description:
  - photosensitivity
  - visuomotor
  - filters
  - biological

### Proposed scoring adaptation

To stay compatible with the documented design, the draft should adapt the Lapan-style `0` to `3` scale:

- `Confortável` = `0`
- `Razoável` = `1`
- `Desconfortável` = `3`

This bootstrap draft intentionally leaves room for later clinical review about whether a three-option questionnaire should instead map to `0, 1, 2`.
The point of the bootstrap is to preserve the Lapan-style upper-bound burden signal for review, not to claim it is final.

### Proposed axis mapping

| Axis | NeuroCheck items | Interpretation focus |
| --- | --- | --- |
| Photosensitivity | 1, 2, 3, 10, 11 | light discomfort, glare, pattern or color discomfort, headache linkage |
| Visuomotor | 4, 5 | motion discomfort, reading strain, visual-vestibular load |
| Filters | 6, 7, 8, 9 | tactile, taste, smell, and auditory filtering sensitivity |
| Biological | 11, 12 and cross-axis accumulation | migraine burden, family history context, cumulative overload risk |

### Biological overload threshold

Bootstrap interpretation rule:

- compute a total burden score across all items
- if total score is greater than `24`, flag the result as compatible with elevated biological overload requiring careful review
- present that threshold as a draft operational rule pending clinical validation

### Draft domain prompt blueprint

```text
Instrument: NeuroCheck sensory and biological overload screener.
Task: convert answers into deterministic scores, summarize burden across Photosensitivity, Visuomotor, Filters, and Biological axes, and identify whether total burden exceeds the draft biological overload threshold of 24.
Scoring: Confortável=0, Razoável=1, Desconfortável=3.
Axis mapping:
- Photosensitivity: items 1, 2, 3, 10, 11
- Visuomotor: items 4, 5
- Filters: items 6, 7, 8, 9
- Biological: item 11, item 12, and cumulative total burden
Safety: describe the threshold as a screener review trigger, not a diagnosis.
```

## Starter Questionnaire Prompt Catalog

| Key | Status | Purpose | Source lineage |
| --- | --- | --- | --- |
| `lapan_q7_clinical_logic` | reviewed starter | visual hypersensitivity screener interpretation | legacy `JsonPrompts.MEDICAL_RECORD_PROMPT` |
| `chyps_v_br20_clinical_logic` | reviewed starter | CHYPS-V-Br 20 interpretation after copy-drift cleanup | current Google Drive inventory described in research brief |
| `neurocheck_clinical_logic` | reviewed starter | four-axis sensory overload interpretation | `neurocheck.json` plus Lapan-derived scoring approach |

## Starter Persona Skill Catalog

| Key | Output profile | Status | Purpose |
| --- | --- | --- | --- |
| `patient_condition_overview` | `patient_condition_overview` | reviewed starter | explain findings in accessible pt-BR for patient or family |
| `clinical_diagnostic_report` | `clinical_diagnostic_report` | reviewed starter | clinician-facing formal report |
| `clinical_referral_letter` | `clinical_referral_letter` | reviewed starter | specialist handoff summary |
| `parental_guidance` | `parental_guidance` | reviewed starter | caregiver guidance with practical next steps |
| `school_report` | `school_report` | reviewed starter | education-facing function and accommodation summary |
| `neuropsychology_summary` | `neuropsychology_summary` | reviewed starter | neuropsychology-oriented synthesis |
| `ophthalmology_screening_summary` | `ophthalmology_screening_summary` | reviewed starter | eye-care oriented screening summary |

## Starter Output Profile Catalog

| Key | Status | Purpose |
| --- | --- | --- |
| `patient_condition_overview` | reviewed starter | readable summary for patient-facing app surfaces |
| `clinical_diagnostic_report` | reviewed starter | formal report for clinicians and chart review |
| `clinical_referral_letter` | reviewed starter | referral-style handoff output |
| `parental_guidance` | reviewed starter | caregiver-oriented explanation |
| `school_report` | reviewed starter | educational accommodations and function summary |
| `neuropsychology_summary` | reviewed starter | cognitive and behavioral summary |
| `ophthalmology_screening_summary` | reviewed starter | ophthalmology-oriented screening summary |

## Starter Access-Point Defaults

These access points are documentation targets so later implementation can bind runtime flows explicitly.

| Access point key | Intended surface | Starter prompt | Starter persona | Starter output profile |
| --- | --- | --- | --- | --- |
| `survey_patient.thank_you.auto_analysis` | patient auto analysis after submission | `lapan_q7_clinical_logic` | `patient_condition_overview` | `patient_condition_overview` |
| `survey_patient.report.manual_generation` | explicit report generation in patient flow | `lapan_q7_clinical_logic` | `clinical_diagnostic_report` | `clinical_diagnostic_report` |
| `survey_frontend.thank_you.auto_analysis` | professional-facing auto analysis | `lapan_q7_clinical_logic` | `clinical_diagnostic_report` | `clinical_diagnostic_report` |
| `survey_frontend.export.school_summary` | school-facing export | `lapan_q7_clinical_logic` | `school_report` | `school_report` |
| `survey_frontend.export.referral_letter` | specialist handoff export | `lapan_q7_clinical_logic` | `clinical_referral_letter` | `clinical_referral_letter` |

## Review Markers

The following labels must remain attached to this pack until a later publication change is approved:

- `reviewed starter`
- `not yet published`
- `pending clinical refinement`
- `pending Mongo seed translation`

## Publication Guardrail

No record in this file should be copied into MongoDB as active content without:

1. clinical review
2. product review
3. privacy review
4. access-point compatibility review
5. versioned publish approval
