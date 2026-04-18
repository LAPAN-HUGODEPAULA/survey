## ADDED Requirements

### Requirement: Prompt-resolution documentation MUST match the questionnaire-plus-persona runtime model
The documented Clinical Writer architecture MUST describe runtime prompt composition as the combination of questionnaire prompts, persona skills, output profiles, and access-point bindings rather than as one undifferentiated prompt document.

#### Scenario: Engineer consults prompt-resolution documentation
- **WHEN** a developer or operator reads the Clinical Writer prompt-resolution reference
- **THEN** the documentation MUST describe how questionnaire prompts and persona skills are combined for runtime execution
- **AND** it MUST explain how access-point configuration selects the final stack for a given flow

### Requirement: The platform MUST provide a research brief before publishing the bootstrap catalog
Before the initial catalog is published to Mongo for runtime use, the platform MUST provide a structured research brief that supports deeper prompt-quality review and refinement.

#### Scenario: Team prepares a prompt-quality review cycle
- **WHEN** the team is ready to refine the starter catalog with deeper prompt research
- **THEN** the documentation set MUST include a research brief summarizing the current architecture, open quality questions, and evaluation criteria
- **AND** the brief MUST be detailed enough to support an external or internal Deep Research workflow
