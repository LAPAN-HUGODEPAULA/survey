## Why

O `agent_graph.py` ainda depende de contratos implícitos entre nós para transportar contexto, fatos clínicos e saída final, o que dificulta evoluir a cadeia Analyzer-Writer com segurança. Esta mudança formaliza o grafo em camadas com `ContextLoader`, `ClinicalAnalyzer` e `PersonaWriter`, torna explícita a fronteira entre análise clínica e escrita de persona, reforça a tipagem estrita do `AgentState` com `TypedDict` e reduz o risco de regressões nos serviços FastAPI que já consomem o grafo compilado.

## What Changes

- Refatorar a orquestração do `clinical-writer-api` para tratar `ClinicalAnalyzer` e `PersonaWriter` como uma cadeia explícita e obrigatória, sem dependência de nós monolíticos de escrita.
- Exigir que o `ContextLoader` hidrate o estado com dados e prompts resolvidos do banco, via `PromptRegistry`, antes da execução dos nós de análise e escrita.
- Formalizar um contrato estrito de `AgentState` com chaves tipadas para contexto carregado, fatos clínicos intermediários, saída final e sinalização de erro.
- Garantir que o Analyzer produza apenas JSON estruturado (`clinical_facts`) e que o Writer consuma apenas esse JSON estruturado junto das instruções de persona.
- Preservar a compatibilidade dos fluxos FastAPI existentes, incluindo a assinatura de `create_graph`, o singleton compilado consumido por `main.py`, o contrato do endpoint `/process`, o tratamento de erro e o uso de dependências já injetadas no serviço.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `layered-graph-orchestration`: endurecer os requisitos do grafo em camadas para exigir `AgentState` estritamente tipado, handoff explícito Analyzer→Writer e preservação da cadeia `ContextLoader` → `ClinicalAnalyzer` → `PersonaWriter`.
- `clinical-writer-prompt-resolution`: explicitar que o `ContextLoader` deve hidratar o estado a partir do banco antes da análise/escrita e manter fallback ou erro acionável sem quebrar os serviços FastAPI existentes.

## Impact

- Affected code:
  - `services/clinical-writer-api/clinical_writer_agent/agent_graph.py`
  - `services/clinical-writer-api/clinical_writer_agent/agents/agent_state.py`
  - `services/clinical-writer-api/clinical_writer_agent/agents/context_loader_agent.py`
  - `services/clinical-writer-api/clinical_writer_agent/agents/clinical_analyzer_agent.py`
  - `services/clinical-writer-api/clinical_writer_agent/agents/persona_writer_agent.py`
  - `services/clinical-writer-api/clinical_writer_agent/main.py`
  - `services/clinical-writer-api/clinical_writer_agent/tests/`
- Affected systems:
  - `services/clinical-writer-api`
- Affected APIs:
  - FastAPI `POST /process` response and failure semantics must remain backward compatible.
