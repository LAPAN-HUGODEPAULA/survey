# LangGraph Orchestration Pipeline

Canonical visualization of the Clinical Writer state graph.

```mermaid
flowchart TD
    START([Request]) --> validate_input
    validate_input -->|"validated"| route_input
    validate_input -->|"flagged"| handle_other

    route_input -->|"consult\nsurvey7\nfull_intake"| context_loader
    route_input -->|"invalid"| handle_other

    context_loader -->|"ok"| clinical_analyzer
    context_loader -->|"error"| handle_other

    clinical_analyzer -->|"ok"| persona_writer
    clinical_analyzer -->|"error"| handle_other

    persona_writer -->|"ok"| END([Report])
    persona_writer -->|"error"| handle_other

    handle_other --> END2([Fallback Response])

    style handle_other fill:#fee2e2,stroke:#dc2626,color:#991b1b
    style END fill:#bbf7d0,stroke:#16a34a,color:#166534
    style END2 fill:#fef3c7,stroke:#d97706,color:#92400e
```

## Notes

- The **ReflectorNode** (reflection-based safety validation with PASS/FAIL loop up to 2 retries) was temporarily bypassed in the `optimize-ai-graph-and-fix-glm` change (May 2026) to reduce token consumption. The architectural intent is preserved — the code remains available for re-enabling.
- **OtherInputHandler** catches all error states, flagged content, and invalid input types, returning a minimal safe response.
- **Model routing** uses a primary (GLM) / fallback (Gemini) policy at the executor level, with higher-level agent catalog routing managed through Survey Builder.
