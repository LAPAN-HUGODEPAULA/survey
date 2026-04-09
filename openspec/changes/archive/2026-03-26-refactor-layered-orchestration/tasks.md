# Implementation Tasks

1. **Update State Definition**
   - [x] Modificar `AgentState` em `services/clinical-writer-api/clinical_writer_agent/agents/agent_state.py` para incluir os novos campos (`clinical_facts`, `draft_narrative`, `interpretation_prompt`, `persona_prompt`).
   - [x] *Validation:* Tentativa de executar checagem de tipagem (Mypy) no projeto. O ambiente atual não possui `mypy` instalado (`uv run mypy clinical_writer_agent` falhou com `No such file or directory`).

2. **Create New Graph Nodes**
   - [x] Implementar `ContextLoader` (`context_loader_agent.py`) com lógica de mock inicial ou integração com a abstração de MongoDB, mapeando `prompt_key`/`persona_key` para strings de instruções.
   - [x] Implementar `ClinicalAnalyzer` (`clinical_analyzer_agent.py`) configurado para produzir `clinical_facts` em JSON via prompt restritivo + parser estruturado.
   - [x] Implementar `PersonaWriter` (`persona_writer_agent.py`) para gerar o `ReportDocument` final a partir do estado `clinical_facts`, preservando `draft_narrative` no estado para auditoria/compatibilidade.
   - [x] *Validation:* Escrever testes unitários isolados (`pytest`) para cada agente simulando chamadas de LLM ou mockando retornos.

3. **Refactor Graph Topology**
   - [x] Modificar `services/clinical-writer-api/clinical_writer_agent/agent_graph.py`.
   - [x] Substituir as arestas diretas do validador para os nós monolíticos por uma rota que vá para o `ContextLoader`.
   - [x] Ligar `ContextLoader` -> `ClinicalAnalyzer` -> `PersonaWriter`.
   - [x] (Opcional, se o escopo permitir) Enviar diretamente ao `END`, mantendo `handle_other` como caminho seguro de erro.
   - [x] *Validation:* Garantir que os testes de fluxo de grafo passem; o teste cobre `draw_ascii()` quando a dependência opcional está disponível e faz fallback para inspeção estrutural dos nós quando `grandalf` não está instalado.

4. **Integration & Compatibility**
   - [x] Adaptar os modelos Pydantic ou rotas do FastAPI (`main.py` ou handlers) caso a resposta deva acomodar a estrutura de `clinical_facts` provisória (se necessário para logs).
   - [x] Manter a injeção do `CompositeMonitor` e testar se os logs e métricas ainda são capturados em cada etapa do novo pipeline.
   - [x] *Validation:* Executar requisições de teste simuladas via `pytest` cobrindo o fluxo `process_content` e métricas. `docker compose up` + `curl` não foram executados neste ambiente.
