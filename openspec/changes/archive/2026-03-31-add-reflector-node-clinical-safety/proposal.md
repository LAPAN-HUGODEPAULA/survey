## Why

O grafo atual encerra a geração após o `PersonaWriter`, sem uma etapa obrigatória de crítica que valide segurança clínica e adequação do texto ao destinatário. Isso é insuficiente para laudos não-médicos, como relatórios escolares, onde um erro de tom ou a presença de recomendações médicas invasivas precisa ser bloqueado e corrigido antes da resposta final.

## What Changes

- Adicionar um `ReflectorNode` ao grafo de laudos como um "Juiz IA" executado após o `PersonaWriter`.
- Exigir que o `ReflectorNode` use um modelo superior de crítica para validar o laudo gerado segundo critérios mínimos de segurança e adequação de audiência.
- Introduzir um ciclo de correção `PersonaWriter` → `ReflectorNode` com feedback estruturado quando o laudo falhar na revisão.
- Definir um número máximo de iterações de reflexão para evitar loops infinitos e degradar para falha acionável quando o limite for atingido.
- Formalizar a regra de que laudos não-médicos não podem conter prescrições, recomendações médicas invasivas ou orientação clínica incompatível com o perfil de saída.

## Capabilities

### New Capabilities
- `clinical-report-reflection`: validação reflexiva de segurança clínica e adequação de audiência para laudos gerados, com feedback corretivo e limite de tentativas.

### Modified Capabilities
- `layered-graph-orchestration`: ampliar o grafo em camadas para incluir `ReflectorNode` após o `PersonaWriter` e suportar loop de correção controlado antes da finalização.
- `generate-clinical-documents`: endurecer a geração de laudos para exigir revisão automática do conteúdo antes da entrega final quando houver perfis sensíveis à audiência, como relatórios escolares.

## Impact

- Affected code:
  - `services/clinical-writer-api/clinical_writer_agent/agent_graph.py`
  - `services/clinical-writer-api/clinical_writer_agent/agents/agent_state.py`
  - `services/clinical-writer-api/clinical_writer_agent/agents/persona_writer_agent.py`
  - `services/clinical-writer-api/clinical_writer_agent/agents/reflector_node.py` or equivalent new module
  - `services/clinical-writer-api/clinical_writer_agent/main.py`
  - `services/clinical-writer-api/clinical_writer_agent/tests/`
- Affected systems:
  - `services/clinical-writer-api`
- Affected APIs:
  - FastAPI `POST /process` must preserve backward compatibility while adding internal reflection retries and actionable failure semantics when reflection cannot converge.
- Affected dependencies:
  - superior critique-model configuration may need to be introduced or documented for the reflection stage.
