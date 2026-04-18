## 1. Inventory and decomposition

- [x] 1.1 Decompose the legacy `Lapan7` prompt (from `prompts.py`) into Questionnaire-Prompt, Persona-Skill, and Output-Profile components.
- [x] 1.2 Draft the `NeuroCheck` domain prompt by adapting the Lapan7 0-3 scoring logic to the 4 NeuroCheck axes and biological overload threshold (>24).
- [x] 1.3 Produce a documented bootstrap catalog that proposes starter questionnaire prompts, persona skills, and output profiles with clear source lineage.
- [x] 1.4 Mark the bootstrap pack explicitly as a reviewed starting point pending further refinement before Mongo publication.

## 2. Documentation and runbooks

- [x] 2.1 Write the English technical documentation that explains the prompt taxonomy, authoring boundaries, runtime composition model, and governance rules.
- [x] 2.2 Document the "Active Version" lifecycle, including the two-step (Save vs. Publish) workflow and version increment rules.
- [x] 2.3 Write a Portuguese admin runbook that explains how the designated builder admin registers, reviews, updates, and validates prompt-catalog entries safely, using structured examples.
- [x] 2.4 Add privacy guidance that forbids PHI, secrets, and unsafe sample content in prompts, examples, and seed materials.

## 3. Research preparation and handoff

- [x] 3.1 Create a detailed Deep Research brief that summarizes the current architecture, quality risks, target outcomes, and evaluation criteria for prompt refinement.
- [x] 3.2 Review the documentation set against the planned access-point model to ensure terminology and structure match the intended runtime architecture.
- [x] 3.3 Prepare the approved documentation outputs so a later implementation change can translate the reviewed bootstrap pack into Mongo seed data.
