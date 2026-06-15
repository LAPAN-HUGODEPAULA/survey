# Delta for clinical-writer-agent

## ADDED Requirements

### Requirement: Four-Stage Clinical Writer Graph

Clinical Writer report generation SHALL preserve the ordered ContextLoader, ClinicalAnalyzer, PersonaWriter, and ReflectorNode workflow.

#### Scenario: Default flow

- GIVEN valid survey response input and configured prompts/persona skills, WHEN /process is invoked, THEN the graph MUST load context, analyze clinically, write according to persona, and apply reflection before returning JSON ReportDocument output.

#### Scenario: Missing prompt

- GIVEN required prompt metadata is missing, WHEN context loading or prompt resolution runs, THEN the graph MUST fail with a structured non-hallucinated error.

### Requirement: Clinical Writer Component Boundaries

Graph nodes SHALL depend on explicit abstractions for prompt registry, model routing, monitoring, and persistence rather than direct cross-layer access.

#### Scenario: Registry abstraction

- GIVEN a graph node needs prompt or persona content, WHEN it resolves the dependency, THEN it MUST use the registry abstraction rather than direct MongoDB or Google client calls.

