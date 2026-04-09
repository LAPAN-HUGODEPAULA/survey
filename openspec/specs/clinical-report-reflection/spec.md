# clinical-report-reflection Specification

## Purpose
TBD - created by archiving change add-reflector-node-clinical-safety. Update Purpose after archive.
## Requirements
### Requirement: Clinical Writer MUST review generated reports with a dedicated reflection node before final delivery.

The clinical writer pipeline MUST execute a dedicated `ReflectorNode` after report generation to evaluate whether the draft is safe and appropriate for the target audience. The node MUST produce a structured review outcome indicating PASS or FAIL, and MUST provide corrective feedback when the draft is rejected.

#### Scenario: Reflection approves a safe audience-appropriate report
- **WHEN** the `ReflectorNode` evaluates a generated report whose tone matches the target audience and whose content satisfies the configured safety checks
- **THEN** the node MUST emit a PASS decision
- **AND** the graph MUST allow the report to proceed to final delivery without another writing pass

### Requirement: Clinical Writer MUST reject non-medical reports that contain invasive medical recommendations.

For non-medical output profiles, including school-facing reports, the `ReflectorNode` MUST reject drafts that contain prescriptions, invasive medical recommendations, or clinical directions inappropriate for the target audience.

#### Scenario: School report contains a prescription
- **GIVEN** a generated report for a school-facing output profile
- **AND** the report contains a medical prescription or invasive recommendation
- **WHEN** the `ReflectorNode` evaluates the draft
- **THEN** it MUST emit a FAIL decision
- **AND** it MUST include corrective feedback instructing the writer to remove the invasive medical guidance and rewrite the report for the school audience

### Requirement: Clinical Writer MUST enforce tone validation for the intended audience.

The `ReflectorNode` MUST validate that the generated report uses tone, vocabulary, and level of instruction appropriate for the configured audience profile.

#### Scenario: Report tone is too clinical for a school audience
- **GIVEN** a generated report for a pedagogical or school-facing profile
- **WHEN** the `ReflectorNode` detects tone that is overly medical, prescriptive, or otherwise inconsistent with the audience
- **THEN** it MUST emit a FAIL decision
- **AND** it MUST instruct the writer to adjust the tone to match the intended recipient

### Requirement: Clinical Writer MUST cap reflection-driven rewrite loops.

The reflection workflow MUST allow at most 2 corrective rewrite iterations after the initial draft. If the draft still fails review after the configured limit, the system MUST stop retrying and surface an actionable failure instead of looping indefinitely.

#### Scenario: Draft never converges after repeated reflection failures
- **GIVEN** a report draft fails reflection repeatedly
- **WHEN** the workflow reaches the second corrective rewrite and the next reflection still fails
- **THEN** the graph MUST stop the reflection loop
- **AND** it MUST surface an actionable failure indicating that safe convergence was not achieved within the allowed iterations

