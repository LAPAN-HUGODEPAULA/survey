# Multi-Agent Architecture for Modular Clinical Documentation

## Introduction

The integration of large language models (LLMs) into the LAPAN healthcare platform — focused on digitizing and validating the Cardiff Hypersensitivity Scale (CHYPS-Br) for neurodevelopmental disorders in Brazil — demands an architecture that goes far beyond simple text generation. The system must produce multiple diagnostic report profiles (clinician, school, patient) from the same questionnaire data, each with distinct tone, vocabulary, and structural requirements.

This document captures the architectural decisions behind the transition from monolithic prompts to a **stateful multi-agent graph** orchestrated by LangGraph. The approach separates clinical interpretation from narrative generation, introduces reflection-based safety cycles, and treats clinical expertise as modular, versionable skills.

## State Graph Orchestration with LangGraph

### From Request-Response to State Graphs

Generating personalized reports for multiple audiences from a single set of questionnaire responses requires a departure from the linear "request-response" model. LangGraph, an extension of the LangChain ecosystem, enables cyclic workflow graphs where each node represents a specific cognitive step: score interpretation, persona selection, narrative writing, or fact validation.

### The Collaborative Whiteboard Pattern

Unlike linear pipelines, a state graph isolates diagnostic interpretation logic from text formatting logic. The shared state acts as a "collaborative whiteboard" where information is aggregated and refined incrementally across nodes.

| Graph Component | Role in Report System | Technical Benefit |
|:---|:---|:---|
| **Classification Node** | Identifies the questionnaire type (e.g., CHYPS-V) and requested report profiles | Dynamic routing; avoids context overload |
| **Interpretation Node** | Applies questionnaire-specific clinical logic to raw patient scores | Centralizes domain knowledge in a modular way |
| **Generation Node (Profile)** | Transforms clinical interpretation into the target audience's tone and structure | Enables parallel generation of multiple reports |
| **Reflection Node** | Self-critiques the generated report against the raw questionnaire data | Drastically reduces extrinsic hallucinations |

By preventing a single "mega-agent" from handling both clinical interpretation and school-friendly formatting simultaneously, the system reduces the probability of omitting critical details or mixing technical terminology with accessible language.

## Thread Persistence and Human-in-the-Loop

The sensitive nature of neurodevelopmental diagnoses demands persistence mechanisms that enable auditing and human review.

### Durable Checkpointing

LangGraph checkpointers — using MongoDB or PostgreSQL backends — save execution state at every "super-step." This allows a clinician to initiate a clinical narrative in the morning and return to review and approve the AI-generated report in the afternoon, without context loss or reprocessing.

| State Strategy | Implementation | Benefit for LAPAN |
|:---|:---|:---|
| **Durable Checkpointers** | MongoDB/PostgreSQL storage | Resilience against server failures during long sessions |
| **Isolated Threads** | Unique identifiers per patient session | Prevents data leakage between patients (LGPD compliance) |
| **State Reducers** | `operator.add` for message history | Maintains complete audit trail of how reports evolved during reflection rounds |

## Composable Prompt Engineering

### The Three-Layer System Message

To satisfy the requirement that report profiles (clinician, school, patient) are reusable across multiple questionnaires, the system uses a "Composable Prompts" strategy. The final prompt is a dynamic object assembled at runtime by merging global guidelines with domain-specific logic.

1. **Interpretation Layer (Domain):** Contains questionnaire-specific clinical rules. For example, if the CHYPS-Br indicates that a score above threshold X in certain questions suggests light hypersensitivity, that logic resides exclusively in this layer.
2. **Persona Layer (Profile):** Defines vocabulary and tone. School reports focus on pedagogical accommodations; neurologist reports use precise technical terminology.
3. **Contextual Data Layer:** The raw JSON with patient responses and metadata, preferably pseudonymized before being sent to third-party models.

This modularity ensures that if a school changes its pedagogical guidelines, the developer updates only the "School Persona" prompt and all questionnaires in the system automatically generate reports in the new format.

### Dynamic Management via Prompt CMS

Prompt management systems (Prompt CMS) such as PromptLayer or LangChain Prompt Hub allow clinical specialists — who may not be familiar with source code — to adjust diagnostic interpretation instructions in real time. Promoting prompts through development, staging, and production environments ensures that changes to diagnostic logic are rigorously tested before reaching patients.

| Management Practice | Description | Operational Impact |
|:---|:---|:---|
| **Immutable Versioning** | Each change generates a new version with a unique ID | Guarantees reproducibility and facilitates clinical audits |
| **Release Labels** | Tags such as `prod`, `beta`, or `test` | Enables prompt updates without code deployments |
| **A/B Testing** | Simultaneous testing of persona variants | Optimizes clarity and patient satisfaction based on real metrics |

## Agent Skills: Modular Expertise

The concept of "Agent Skills," introduced by providers such as Anthropic and adopted by frameworks including Spring AI and LangChain Deep Agents, represents an architectural leap beyond traditional tools. While a tool is an executable function, a Skill is **packaged expertise** that shapes how the agent thinks about and approaches a specific problem.

### Clinical Skills and Progressive Disclosure

Implementing Skills allows the agent to load knowledge only when needed, saving tokens and reducing model attention dispersion.

- **Level 1 (Metadata):** The agent knows only the names and descriptions of available skills (e.g., "CHYPS Interpretation Skill", "School Referral Skill").
- **Level 2 (Instructions):** Only when the system identifies the need for a school report is the corresponding SKILL.md file loaded into the model's context.
- **Level 3 (Scripts and Resources):** The skill may contain Python scripts for complex statistical calculations or report templates in Markdown, loaded on demand.

This architecture solves the "context contamination" problem, where instructions for a medical report could unduly influence a simplified patient report. Furthermore, skills are portable and can be shared among different LAPAN system agents, such as the clinical narrative assistant and the automated report generator.

### Skills vs. Prompts: When to Migrate?

If a questionnaire interpretation instruction is used repeatedly across different conversations and requires a rigid structure, it should "graduate" from a simple prompt to a Skill. Skills allow intelligence to be "embedded" into the agent's behavior, treating clinical knowledge as a dynamic training manual rather than an ephemeral instruction.

## Low-Rank Adaptation (LoRA): Overview and Decision

### What is LoRA?

Low-Rank Adaptation (LoRA) is a Parameter-Efficient Fine-Tuning (PEFT) technique that freezes the original model weights and injects small, trainable low-rank matrices that learn task-specific residuals. This allows fine-tuning for specific styles, tones, or domain knowledge at a fraction of the cost and storage of full model fine-tuning. For example, a single base model could serve reports with radically different styles by swapping lightweight adapters at inference time.

### Why LoRA Is Not Recommended for LAPAN

After careful evaluation, the LAPAN project has decided **not to adopt LoRA** for the following reasons:

1. **API-Only Infrastructure:** The platform relies entirely on third-party API calls (e.g., OpenAI, Google) for LLM inference. LoRA requires self-hosted model serving infrastructure (GPUs, vLLM, or similar), which is outside the project's current scope and budget.
2. **Operational Complexity:** Training, versioning, and serving custom LoRA adapters introduces significant DevOps overhead — adapter storage, A/B testing of adapters, and inference server management — that is disproportionate to the project's current scale.
3. **Composable Prompts as Alternative:** The three-layer composable prompt architecture (Domain + Persona + Context) achieves sufficient tone and style differentiation through prompt engineering alone. Persona skills stored in MongoDB provide versionable, auditable style control without the need for model fine-tuning.
4. **Cost-Benefit Trade-off:** The marginal gains in tonal consistency from LoRA adapters do not justify the infrastructure investment when prompt-based personas already deliver adequate quality for the target report profiles.

If the project scales to the point where prompt-based persona control becomes insufficient — for instance, if dozens of highly specialized output profiles are needed — LoRA can be revisited as a future enhancement.

## Hallucination Mitigation via Reflection Cycles

Medical report generation demands factual rigor with zero tolerance for errors. The Reflexion architecture in LangGraph transforms report generation into an iterative self-critique and correction process.

### Clinical Critique Node

Within the state graph, the initially generated report is not delivered to the user but is instead passed to a "Critique" node. This node acts as an "AI Judge" or "Guardian Agent" that evaluates the draft against a medical quality rubric.

| Reflection Criterion | Verification Question | Correction Mechanism |
|:---|:---|:---|
| **Logical Precision** | Are all conclusions supported by the questionnaire scores? | Comparison against raw state data |
| **Clinical Recall** | Was any relevant alteration detected in the questionnaire omitted? | Medical entity coverage verification |
| **Persona Consistency** | Is the tone appropriate for the target audience (e.g., school)? | Style-rule-based reformatting |

Research shows that "directed" reflection — where the critic specifically points out the error — is superior to blind correction. Additionally, using advanced reasoning models (e.g., GPT-4o, Claude) for the critique phase while faster, smaller models handle the initial draft optimizes cost without sacrificing safety.

### Grounded Verification

To ensure "Intrinsic Truth," reflection must be complemented by rigorous re-reading of the provided context. The MEGA-RAG framework demonstrates that cross-referencing model claims against a curated clinical knowledge base can reduce hallucination rates by over 40%. In the LAPAN context, every assertion in the report (e.g., "The patient presents a score indicative of photophobia") must be explicitly validated against the input JSON in the reflection node before finalization.

## Data Governance and LGPD Compliance

Since the system handles health data from minors in Brazil, compliance with the Lei Geral de Proteção de Dados (LGPD) is a central architectural pillar.

### Privacy in AI Processing

The system implements a "Data Sanitization" layer (PII Masking) before data leaves the controlled environment (survey-backend) for the AI API (clinical-writer-api).

| Security Measure | Technical Implementation | Legal Requirement |
|:---|:---|:---|
| **Pseudonymization** | Replacing names with unique IDs in the state graph | Protection of sensitive data (Art. 13 LGPD) |
| **Prompt Audit Logs** | Recording which prompt version generated which report | Transparency and explainability (Art. 20 LGPD) |
| **Granular Consent** | Permission tags for sharing AI-generated reports | Purpose and necessity (Art. 6 LGPD) |

The integration of "Guardian Agents" in LangGraph acts not only as clinical reviewers but also as compliance monitors, blocking report generation that contains stigmatizing language or data not explicitly authorized by the patient's legal guardian.

## The 4-Stage Orchestration Graph (Implementation Design)

The transition from monolithic prompts to a system based on **Decoupled Expertise** is the fundamental step for the LAPAN platform's growth. By separating **Clinical Interpretation Logic** (Questionnaire Rules) from **Communication Logic** (Persona/Skill), clinical specialists can manage knowledge without depending on software deployment cycles.

### Graph Stages

| Stage | Node | Responsibility | Input | Output |
|:---|:---|:---|:---|:---|
| **1. Context** | ContextLoader | Retrieves the `interpretation_prompt` for the questionnaire and the persona SKILL from MongoDB | Questionnaire ID, Profile ID | Interpretation Prompt, Persona Prompt |
| **2. Analysis** | ClinicalAnalyzer | Processes the response JSON applying only clinical rules (e.g., CHYPS scoring) | Response JSON, Interpretation Prompt | **Structured Analysis JSON** (Clinical Facts) |
| **3. Writing** | PersonaWriter | Transforms clinical facts into a Markdown narrative following the Persona's tone | Analysis JSON, Persona Prompt | Report Draft (Markdown) |
| **4. Critique** | ReflectorNode | The "Judge." Validates tone adequacy and checks for invasive recommendations | Draft, Original Responses, Safety Criteria | **PASS** (End) or **FAIL** (Return to Writing) |

### Why Skills in MongoDB?

Agent Skills (Personas) are stored in MongoDB collections so that the survey-builder application functions as a clinical CMS. This enables:

- **Medical Versioning:** Specialists can create "v2" of a school profile without touching code.
- **API Flexibility:** Different skills can, in the future, be configured to use different models (e.g., GPT-4o for Clinician, GPT-4o-mini for Patient) for cost optimization.

## Cost and Risk Mitigation

The solution uses only standard API calls, eliminating the complexity of self-hosted GPU infrastructure.

1. **Asymmetric Models:** Lightweight models for stages 1-3; high-reasoning models only for the Reflection Node.
2. **Context Hygiene:** By separating interpretation from writing, prompts sent at each step are smaller and more focused, reducing the model's "attention tax" and the probability of hallucinations.

## Implementation Roadmap

Following a **Spec-Driven Design** methodology, the implementation is divided into 5 high-fidelity phases.

### Phase 1: Governance and Data (Foundation)

- Define MongoDB schema for `QuestionnairePrompts` (fields: `interpretation_logic`, `version`, `author`).
- Define MongoDB schema for `PersonaSkills` (fields: `role_name`, `tone_guidelines`, `safety_constraints`, `output_format`).
- Create basic CRUD in survey-builder for medical professionals to edit these fields.

### Phase 2: Analyzer Decoupling

- Refactor LangGraph state to support `ClinicalAnalysis` (internal JSON object).
- Implement the `ClinicalAnalyzer` node. It must produce only cold facts (e.g., "Visual Hypersensitivity: Detected; Severity: Moderate").
- Validate that the Analyzer generates no narrative text — only structured data.

### Phase 3: Persona Engine (Skills Runtime)

- Implement `ContextLoader` node to dynamically fetch prompts based on `profile_id`.
- Implement `PersonaWriter` node consuming Phase 2 output.
- Integrate support for multiple models via MongoDB configuration.

### Phase 4: Safety Layer (Reflection)

- Implement `ReflectorNode` with a specialized prompt for detecting "invasive medical recommendations" (Safety Guardrail).
- Configure the conditional edge (`conditional_edge`) to perform correction loops up to 2 times on failure.

### Phase 5: Integration and CI/CD

- Update API endpoints to accept the new dynamic profile payload.
- Implement regression tests in LangSmith to ensure MongoDB prompt changes do not break report generation.

## Conclusions and Strategic Recommendations

The convergence of LangGraph orchestration, Agent Skills expertise management, and composable prompt engineering constitutes the state-of-the-art approach for automated clinical documentation.

The following strategic guidelines are recommended:

- **Migrate to a Stateful Multi-Agent Architecture:** Implement LangGraph to manage the separation between diagnostic interpretation and persona generation, ensuring persistence and auditability.
- **Standardize Clinical Skills:** Encapsulate each questionnaire's logic (e.g., CHYPS-Br) in file-based modular Skills, facilitating decentralized maintenance by different clinical teams.
- **Institutionalize Reflection Cycles:** Implement reflection and clinical critique nodes in the graph to mitigate hallucinations and ensure all reports are strictly grounded in questionnaire data.
- **Out-of-Code Prompt Governance:** Use a Prompt CMS to manage the lifecycle and versioning of instructions, enabling rapid iterations without complex deployments.
- **Use API-Based Inference with Composable Prompts:** Leverage the composable prompt system (Domain + Persona + Context) for style differentiation rather than fine-tuning, keeping infrastructure simple and costs predictable.

By adopting this modular, state-oriented ecosystem, the system not only addresses the immediate need for multiple reports per questionnaire but also positions itself as a scalable platform capable of absorbing new diagnostic scales and modalities with marginal engineering effort — always prioritizing patient safety and clinical precision.
