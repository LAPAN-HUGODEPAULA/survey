# Design: QuestionnairePrompts and PersonaSkills

## 1. Context

The current Clinical Writer runtime already supports Mongo-backed prompt lookup, but the active model still treats a prompt as one opaque document and retains hardcoded LangGraph prompt fallbacks inside writer nodes. That model is insufficient for the requested behavior because it does not separate:

- questionnaire-specific clinical reasoning
- output-profile tone and restrictions

The requested change introduces two explicit prompt components stored in MongoDB:

- `QuestionnairePrompts`
- `PersonaSkills`

This proposal assumes that "instantaneously" means the next eligible request after a successful MongoDB update must observe the edited persona skill without any deploy or process restart.

## 2. Domain Split

### 2.1. QuestionnairePrompts

`QuestionnairePrompts` stores the clinical reasoning that belongs to the questionnaire itself. This includes instructions such as:

- what symptoms or domains should be emphasized
- how questionnaire answers should be interpreted clinically
- what evidence or caution statements are required for that questionnaire

It must not encode audience tone or report-format persona concerns such as "write for a school team" or "use more conservative language for referral letters".

### 2.2. PersonaSkills

`PersonaSkills` stores the output-profile persona. This includes:

- tone
- intended audience
- style constraints
- safety restrictions
- wording preferences for a given output profile such as `school_report`

This lets a physician update the tone of the school report by editing the persona document without touching questionnaire logic.

## 3. Runtime Resolution Model

For survey-derived requests, `clinical-writer-api` should resolve prompt input in three layers:

1. A stable system frame that enforces JSON-only output and schema compliance.
2. A `QuestionnairePrompts` document that provides questionnaire-specific clinical logic.
3. A `PersonaSkills` document that provides profile-specific style and restrictions.

The effective runtime prompt is the composition of those layers plus the request content.

Hardcoded prompt text inside LangGraph writer nodes should remain only as a migration-time fallback, not the primary configuration source for migrated survey flows.

## 4. Hot Reload and Versioning

The main operational requirement is immediate behavior change after MongoDB edits. The simplest design that satisfies this is correctness-first runtime resolution:

- migrated prompt components are read from MongoDB on the request path
- the runtime exposes traceable versions for both the questionnaire prompt and the persona skill
- no deploy or service restart is required after editing either document

The proposal intentionally avoids requiring aggressive in-process caching for migrated prompt components. A later optimization can add cache invalidation if it preserves the next-request freshness guarantee.

## 5. API and Flow Implications

Survey-based report generation must treat questionnaire logic and output profile as separate decisions.

- The questionnaire selects the `QuestionnairePrompt`.
- The report flow selects or derives the `PersonaSkill`.
- The worker/backend propagates both identities to `clinical-writer-api`.

This removes the need to encode school-report tone, parental-guidance tone, or similar stylistic differences inside questionnaire prompts.

## 6. Migration Strategy

The rollout spans multiple systems, so a design document is necessary.

### 6.1. Data Creation

Migration scripts must:

- create `QuestionnairePrompts`
- create `PersonaSkills`
- backfill questionnaire prompt content from existing Mongo-backed survey prompts where possible
- seed persona skills for currently supported report profiles

### 6.2. Compatibility Window

During migration, the Clinical Writer may still need a controlled fallback for non-migrated prompt keys or non-survey flows. That fallback must be explicit and temporary.

### 6.3. Traceability

Backfilled documents must preserve enough metadata to explain:

- which legacy prompt they came from
- which questionnaire or output profile they now serve
- which version was used at runtime

## 7. Naming Decision

The requested collection names are `QuestionnairePrompts` and `PersonaSkills`. This intentionally differs from the repository's usual lower-snake-case Mongo naming. The change is acceptable here because the collection names are part of the requested operational model and should remain explicit in the specification.
