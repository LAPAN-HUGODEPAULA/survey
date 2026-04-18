## Context

The Clinical Writer prompt ecosystem is currently split between Google Drive documents, emerging Mongo-backed prompt catalogs, and partially wired builder CRUD screens. Prompt structure is not documented clearly enough for future operators, the current inventory includes content drift and audience mismatches, and the runtime target architecture now depends on a cleaner questionnaire-prompt plus persona-skill model. Before publishing canonical records into Mongo, the team needs a detailed architecture reference, a bootstrap catalog plan, and a Portuguese runbook for the administrator who will operate the builder.

This change is documentation-heavy, but it still has architectural implications because the documentation must match the runtime composition model and seed structure that later implementation will rely on.

## Goals / Non-Goals

**Goals:**
- Document the structure and responsibilities of questionnaire prompts, persona skills, output profiles, and agent access points.
- Produce a detailed bootstrap inventory derived from the current Google Drive prompt set, decomposed into reusable catalog components.
- Create a Portuguese runbook for the admin responsible for registering and maintaining prompts in `survey-builder`.
- Create a Deep Research brief that supports iterative refinement of prompt quality before Mongo publication.
- Define a seed-ready starting catalog without claiming it is the final reviewed prompt set.

**Non-Goals:**
- Automatically publishing the final reviewed prompt catalog to Mongo in this change.
- Building new runtime behavior beyond the documentation and bootstrap structure needed to support later implementation.
- Replacing the need for expert review of clinical prompt quality.

## Decisions

1. **Adopt a Three-Layer Prompt Stack Architecture**
   The documentation will standardize the "Prompt Stack" model where runtime behavior is composed of three distinct layers:
   - **Questionnaire Prompt (Domain):** Clinical interpretation logic (e.g., scoring, axis mapping, diagnostic rules).
   - **Persona Skill (Voice):** Tone, vocabulary, and audience-specific constraints (e.g., formal clinician vs. patient-facing).
   - **Output Profile (Structure):** Structural and format constraints (e.g., JSON schema for apps, Markdown for records).

2. **Decompose Legacy Lapan7 as the Governance Blueprint**
   The monolithic `Lapan7` prompt (currently in `prompts.py`) will be decomposed into these layers to serve as the template for all future clinical agents.

3. **Use Lapan7 as the Foundation for NeuroCheck**
   The new `NeuroCheck` prompt will be documented by adapting the Lapan7 interpretation logic (0-3 scoring) to the 4 NeuroCheck axes (Photosensitivity, Visuomotor, Filters, Biological) and its >24 biological overload threshold.

4. **Implement an "Active Version" Two-Step Publishing Model**
   To balance iteration speed during internal testing with operational safety, the system will use:
   - **Step 1: Save (Draft):** Persists changes to the database as a "draft" state, not visible to the runtime clinical writer.
   - **Step 2: Publish (Active):** Increments the version number and marks the prompt as the "active" version for runtime selection.
   - **Immutable History:** Every "Publish" action creates a versioned record in the catalog to allow for audit trails and future rollbacks.

5. **Focus the Runbook on Structure and Examples**
   The Portuguese admin runbook will prioritize:
   - **Formatting & Structure:** How to organize scoring rules and mapping tables so the AI understands them reliably.
   - **Content Requirements:** Mandatory elements for each layer (e.g., pt-BR language constraints, audience definition).
   - **Visual Examples:** Using "Before/After" or "Blueprint" examples to illustrate successful prompt construction without deep-diving into prompt engineering theory.

6. **Separate Governance Documentation from Publication**
   The change will define the prompt architecture and bootstrap content in documentation first, then leave actual Mongo publication to a follow-on implementation.

## Risks / Trade-offs

- [Risk] The bootstrap catalog could be mistaken for final approved prompt content. → Mitigation: label it clearly as a reviewed starting point pending clinical and product validation.
- [Risk] Documentation can drift from implementation. → Mitigation: tie the documented taxonomy to the same capability specs used for later implementation.
- [Risk] Deep Research recommendations may diverge from current runtime constraints. → Mitigation: include explicit repository context, current architecture, and evaluation criteria in the research brief.

## Migration Plan

1. Inventory the current Google Drive prompts and map them to questionnaire, persona, output-profile, and access-point concerns.
2. Publish the architecture reference, governance rules, and Portuguese admin runbook.
3. Produce a bootstrap seed pack and Deep Research brief for iterative refinement.
4. Review and refine the proposed prompt pack before any Mongo publication or runtime cutover.

## Open Questions

- Should the bootstrap pack live only in documentation first, or also in versioned JSON fixtures before Mongo publication?
- What approval workflow will be required before a prompt moves from “bootstrap draft” to “published catalog entry”?
