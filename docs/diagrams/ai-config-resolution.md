# AI Configuration Resolution Chain

How AI model configuration is resolved at runtime.

```mermaid
flowchart TD
    REQ([Incoming Request]) -->|optional overrides| REQ_CFG[Request aiConfig]
    REQ_CFG --> AP[Resolve Access Point]

    AP -->|accessPointKey| AP_CFG[Access Point aiConfig]
    AP -->|promptKey| PROMPT[Questionnaire Prompt]
    AP -->|personaSkillKey| PERSONA[Persona Skill]

    AP_CFG --> GLOBAL[Global AI Config<br/>/settings/ai]
    GLOBAL --> ENV[Environment Variables<br/>CLINICAL_WRITER_API_TOKEN]

    REQ_CFG --> MODEL[Model Resolution]
    AP_CFG --> MODEL
    GLOBAL --> MODEL
    ENV --> MODEL

    MODEL --> AGENT[Agent Catalog<br/>AIAgents collection]
    AGENT --> PRIMARY[Primary Agent<br/>openai_compatible / glm / gemini]
    PRIMARY -->|fail| FALLBACK[Fallback Agent]
    FALLBACK --> EXEC[Execute LLM Call]
    PRIMARY --> EXEC

    style REQ fill:#dbeafe,stroke:#2563eb,color:#1e3a5f
    style EXEC fill:#bbf7d0,stroke:#16a34a,color:#166534
    style AGENT fill:#fef3c7,stroke:#d97706,color:#78350f
```

## Resolution Precedence

For prompt/persona/output selection:
1. Explicit request overrides
2. Access point bindings
3. Survey defaults

For AI model selection:
1. Explicit request `aiConfig`
2. Access point `aiConfig`
3. Global singleton `aiConfig` (`/settings/ai`)
4. Environment variable fallback

## Agent Catalog

Access points define an ordered `agentRefs` list with primary and fallback agents. If the primary agent fails, the system tries the next enabled agent in order. Agent definitions are stored in the `AIAgents` MongoDB collection and managed through Survey Builder.
