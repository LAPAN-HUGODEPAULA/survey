## Context

The `clinical-writer-api` already separates the pipeline into `ContextLoader`, `ClinicalAnalyzer`, and `PersonaWriter`, but it still delivers the final report immediately after writing. This leaves unenforced a requirement already implicit in the project's multi-agent architecture: the existence of a critique node capable of validating clinical safety, adherence to the recipient, and grounding of the text before the final response.

The main constraints of this design are:
- the `POST /process` endpoint SHALL remain externally compatible with current FastAPI services;
- the reflection loop SHALL NOT introduce unlimited recursion or limitless latency;
- the critique node SHALL apply mandatory minimum criteria even when the output profile is not medical;
- the additional reflection cost SHALL be concentrated in a superior model, without reconfiguring the analysis and writing nodes.

Main stakeholders:
- `clinical-writer-api` team, responsible for the graph and report safety;
- FastAPI consumers who depend on the current `ProcessResponse` contract;
- clinicians, researchers, and non-medical recipients, such as schools and families, who require appropriate tone and the absence of undue clinical instructions.

## Goals / Non-Goals

**Goals:**
- Insert `ReflectorNode` as a mandatory fourth stage after `PersonaWriter` to review the report before finalization.
- Make the `ReflectorNode` operate as an "AI Judge" using a superior critique model, separately configurable from the analysis and writing models.
- Define an explicit contract in the state for corrective feedback, reflection status, and iteration counter.
- Require minimum validation of appropriate tone for the recipient and the absence of invasive medical recommendations in non-medical reports.
- Forward reflection failures back to `PersonaWriter` with structured feedback, up to a maximum number of 2 corrective iterations.
- Terminate with an actionable error when the report does not converge after the correction limit.

**Non-Goals:**
- Redesign the `clinical-writer-api` HTTP payload to expose the judge's full opinion in the external contract.
- Implement human review, asynchronous queues, or persistent checkpoints in this change.
- Introduce new MongoDB collections to store reflection history.
- Make the `ReflectorNode` responsible for re-analyzing raw clinical content; its function is to judge the writer's output, not to replace the analyzer.

## Decisions

### Decision: Model reflection as an explicit state stage rather than validation embedded in the Writer

`ReflectorNode` SHALL be a distinct node in the `StateGraph`, always executed after `PersonaWriter`. It SHALL read `report`, `draft_narrative`, `clinical_facts`, `output_profile`, and audience metadata, and SHALL produce a structured verdict in the state, for example: `reflection_status`, `reflection_feedback`, `reflection_iteration`, `reflection_decision`.

Rationale:
- maintains clear separation between generation and judgment;
- makes the Writer→Reflector cycle observable and testable;
- prevents the writer from silencing its own error or "self-approving" an unsafe report.

Alternative considered:
- add safety validations directly into `PersonaWriter`.
  - rejected because it mixes production and review, reducing traceability and making correction loop testing difficult.

### Decision: Use a dedicated superior model for the `ReflectorNode`

`ReflectorNode` SHALL use an explicitly configured critique model, such as `GPT-4o` or a superior equivalent, separate from the models used by `ClinicalAnalyzer` and `PersonaWriter`. The graph contract SHALL allow injection of this model by dependency or factory without breaking `create_graph(...)`.

Rationale:
- critique requires more reliability and judgment than the initial writing;
- concentrates additional cost only on the safety stage;
- allows rapid testing with doubles while maintaining production on a more robust model.

Alternative considered:
- reuse the same writer model for critique.
  - rejected because it reduces review independence and weakens the safety barrier.

### Decision: Formalize structured corrective feedback and a maximum of 2 corrective iterations

When reflection fails, the node SHALL return structured feedback to `PersonaWriter` containing at least: reason for rejection, violated criterion, and correction instruction. The graph SHALL allow a maximum of 2 rewrites triggered by reflection. After that, the flow SHALL terminate with an actionable error, instead of an infinite loop or forced approval.

Rationale:
- sets a predictable latency and cost limit;
- transforms critique into objective input for rewriting;
- avoids infinite loops in prompts or profiles that are difficult to satisfy.

Alternative considered:
- allow an indefinite number of reviews until PASS is obtained.
  - rejected because it makes the system non-deterministic and can generate uncontrolled cost/latency.

### Decision: Treat non-medical reports as profiles with reinforced safety policy

Profiles such as `school_report`, `educational_support_summary`, `parental_guidance`, and non-medical equivalents SHALL activate reinforced validation against prescriptions, prescriptive diagnoses, or invasive recommendations. In case of violation, the `ReflectorNode` SHALL mandatory reject the report and instruct correction.

Rationale:
- the risk of harm is greater when a non-medical recipient receives prescriptive language;
- makes the school scenario rule required by the change testable;
- aligns the review with the output profile semantics already present in the state.

Alternative considered:
- apply exactly the same rubric for all profiles.
  - rejected because it does not capture the specific audience risk and weakens the safety policy.

### Decision: Preserve the `/process` external contract and expose convergence failure only as an actionable error

The endpoint SHALL continue returning `ProcessResponse` without new mandatory fields. When reflection definitely fails, the service SHALL respond with an actionable error compatible with the current track of internal failures, instead of returning an unsafe report or a partially approved payload.

Rationale:
- avoids breaking changes for current consumers;
- maintains the safety barrier within the graph implementation;
- prevents delivery of an unsafe report in case of non-convergence.

Alternative considered:
- always return the last draft with warnings.
  - rejected because it normalizes delivery of content rejected by the judge.

## Risks / Trade-offs

- [Risk] Reflection increasing perceived latency in `/process`. → Mitigation: limit to 2 corrective iterations and use a superior model only in the critique node.
- [Risk] The judge's feedback being vague and not helping the writer converge. → Mitigation: require a structured payload with the violated criterion and explicit correction instruction.
- [Risk] Incorrect classification of non-medical profiles letting invasive content pass. → Mitigation: map sensitive profiles in the design and cover with contract tests.
- [Risk] Legitimate medical profile reports being blocked by excessively rigid rules. → Mitigation: condition the invasive prohibition rule to the type of audience/output profile.
- [Risk] The correction loop modifying clinical facts instead of just reformulating the narrative. → Mitigation: maintain `clinical_facts` as an immutable clinical source and allow the writer to alter only the report.

## Migration Plan

1. Add the delta specs for graph topology, document generation, and clinical reflection.
2. Expand `AgentState` with reflection fields, iteration counter, and corrective feedback.
3. Implement `ReflectorNode` and the conditional edge `PersonaWriter` → `ReflectorNode` → (`END` or `PersonaWriter`/error).
4. Introduce superior critique model configuration preserving the public signature of `create_graph(...)`.
5. Update unit and contract tests for PASS, FAIL with correction, and FAIL by exceeding limit scenarios.
6. Deploy without external contract change; rollback consists of removing the reflection stage and restoring the previous topology.

## Open Questions

- Should the non-convergence error after 2 iterations use a new specific `error_kind`, such as `reflection_failed`, or reuse a generic generation category?
- Should `ReflectorNode` feedback be persisted only in internal logs/observability or also in future structured auditing?
