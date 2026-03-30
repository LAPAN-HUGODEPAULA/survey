## Context

O `clinical-writer-api` já possui os nós `ContextLoaderAgent`, `ClinicalAnalyzerAgent` e `PersonaWriterAgent`, e o endpoint FastAPI `POST /process` já depende do grafo compilado para produzir `ProcessResponse`. Mesmo assim, a refatoração ainda precisa consolidar o contrato entre esses nós no `agent_graph.py`, explicitar quais chaves do estado são obrigatórias em cada fase e impedir que a evolução do fluxo em camadas quebre a compatibilidade dos serviços existentes.

As principais restrições são:
- o estado compartilhado precisa permanecer rastreável e validável ao longo do grafo;
- a hidratação de contexto deve continuar vindo do banco via `PromptRegistry` e dependências FastAPI existentes, sem lookup direto em nós downstream;
- o endpoint `/process` não pode sofrer quebra de contrato enquanto a cadeia Analyzer-Writer é endurecida.

Stakeholders principais:
- equipe do `clinical-writer-api`, que mantém o grafo e os agentes;
- serviços FastAPI e consumidores internos que dependem de `ProcessResponse`;
- clínicos e pesquisadores que editam prompts e skills no banco sem redesploy da aplicação.

## Goals / Non-Goals

**Goals:**
- Refatorar `agent_graph.py` para que ele represente explicitamente uma cadeia em camadas `ContextLoader` → `ClinicalAnalyzer` → `PersonaWriter` para os fluxos suportados.
- Tornar explícita a sequência `ContextLoader` → `ClinicalAnalyzer` → `PersonaWriter` como caminho obrigatório para fluxos suportados.
- Definir um `AgentState` estrito com `TypedDict`, separando claramente chaves de entrada, contexto hidratado, fatos clínicos, saída final e sinalização de erro.
- Garantir que o `ClinicalAnalyzer` produza somente `clinical_facts` estruturado e que o `PersonaWriter` use esse artefato como única base clínica para geração.
- Preservar o comportamento externo dos serviços FastAPI atuais, incluindo injeção de dependências, assinatura de `create_graph`, semântica de erro e estrutura da resposta do `/process`.

**Non-Goals:**
- Redesenhar o contrato HTTP do `clinical-writer-api`.
- Introduzir novos modelos de banco ou novas coleções para prompts/personas.
- Alterar a política de fallback além do necessário para manter fluxos legados operacionais.
- Implementar novas etapas de reflexão ou expandir o escopo para outros serviços do monorepo.

## Decisions

### Decision: Consolidar o `AgentState` como contrato estrito entre nós

O estado compartilhado continuará baseado em `TypedDict`, mas a mudança vai distinguir explicitamente:
- campos de entrada (`input_content`, `input_type`, `prompt_key`, `persona_skill_key`, `output_profile`);
- contexto hidratado (`interpretation_prompt`, `persona_prompt`, versões resolvidas);
- saída intermediária (`clinical_facts`);
- saída final (`report`, `draft_narrative`, `medical_record`);
- metadados operacionais (`request_id`, `observer`, `prompt_registry`, `error_kind`, `error_message`, `validation_status`).

Rationale:
- reduz ambiguidade sobre o que cada nó lê e escreve;
- facilita testes unitários do handoff Analyzer→Writer;
- evita que nós futuros dependam de chaves implícitas ou payloads combinados.

Alternative considered:
- manter um `dict[str, Any]` flexível com convenções por documentação.
  - rejeitado porque aumenta risco de regressão silenciosa e enfraquece a verificabilidade do pipeline.

### Decision: Formalizar a fronteira Analyzer-Writer por dados estruturados

O `ClinicalAnalyzer` deverá consumir apenas `input_content` e `interpretation_prompt` para produzir `clinical_facts`, sem narrativa orientada ao usuário. O `PersonaWriter` deverá consumir `clinical_facts` e `persona_prompt`, sem reinterpretar diretamente o conteúdo bruto do request como fonte clínica primária.

Rationale:
- separa interpretação clínica de formatação narrativa;
- reduz acoplamento entre regra clínica e tom de escrita;
- cria um artefato intermediário observável e testável.

Alternative considered:
- permitir que o `PersonaWriter` releia `input_content` para “completar” o texto final.
  - rejeitado porque reintroduz a mistura entre análise clínica e prosa, reduzindo rastreabilidade.

### Decision: Tratar `ContextLoader` como a única porta de hidratação de contexto do banco

O grafo continuará resolvendo prompts via `PromptRegistry` injetado pelos serviços FastAPI, mas a especificação passará a exigir que a hidratação do estado ocorra no `ContextLoader` antes de qualquer análise ou escrita. O nó deverá preencher os prompts separados, as versões resolvidas e quaisquer metadados de contexto necessários para o handoff Analyzer→Writer, além de retornar erro acionável ou fallback controlado quando a migração de prompts não estiver completa.

Rationale:
- centraliza a leitura de contexto e evita duplicação de resolução em nós downstream;
- preserva o comportamento atual de atualização dinâmica via banco;
- simplifica o rastreamento de versões retornadas ao endpoint.

Alternative considered:
- mover a resolução de prompts para dentro de `ClinicalAnalyzer` e `PersonaWriter`.
  - rejeitado porque duplica dependências, dificulta observabilidade e enfraquece o papel do grafo como pipeline determinístico.

### Decision: Preservar compatibilidade do `/process` como requisito de refatoração

A refatoração do grafo não deverá alterar os modelos FastAPI já expostos nem a forma como `main.py` injeta `graph`, `observer` e `prompt_registry`. Ela também não deverá exigir mudanças na assinatura pública de `create_graph` nem no singleton `clinical_writer_graph` já consumido pelo serviço. O fluxo poderá endurecer suas pré-condições internas, mas deve continuar:
- recebendo o mesmo `ProcessRequest`;
- retornando `ProcessResponse` com `report` válido e versões de prompt quando disponíveis;
- convertendo falhas de resolução em erro HTTP acionável, sem mudar o contrato externo.

Rationale:
- reduz risco de quebra para consumidores já integrados;
- permite refatorar a implementação sem exigir rollout coordenado entre serviços.

Alternative considered:
- aproveitar a refatoração para alterar a resposta do endpoint e expor `clinical_facts`.
  - rejeitado nesta mudança porque aumentaria o escopo e criaria breaking change desnecessária.

## Risks / Trade-offs

- [Risco] `TypedDict` estrito demais dificultar fluxos legados ou testes antigos. → Mitigação: usar chaves opcionais somente para campos realmente transitórios e alinhar fixtures/testes do grafo com o novo contrato.
- [Risco] `PersonaWriter` ainda depender implicitamente de `input_content` por código legado ou prompts antigos. → Mitigação: ajustar prompts, testes e validações para reforçar `clinical_facts` como única base clínica.
- [Risco] Falhas de resolução no `ContextLoader` gerarem regressão operacional no `/process`. → Mitigação: manter fallback controlado onde documentado e preservar mapeamento atual de `prompt_not_found` para erro HTTP acionável.
- [Risco] A refatoração formalizar comportamento já parcialmente implementado sem eliminar todas as rotas implícitas. → Mitigação: adicionar testes de contrato do grafo e do endpoint cobrindo a cadeia completa e os estados intermediários.

## Migration Plan

1. Atualizar os delta specs para fixar os requisitos de estado, hidratação e compatibilidade.
2. Ajustar `AgentState`, `agent_graph.py` e agentes relacionados para alinhar leitura/escrita de estado ao contrato especificado.
3. Reforçar testes unitários do `ContextLoader`, `ClinicalAnalyzer` e `PersonaWriter`, além dos testes do endpoint `/process`.
4. Validar que o grafo compilado continua aceitando as dependências injetadas atuais e que os fluxos FastAPI não exigem alteração de payload.
5. Implantar sem mudança de contrato externo; rollback consiste em restaurar a topologia e o estado anteriores, já que a API pública permanece a mesma.

## Open Questions

- O fluxo legado que hoje usa `resolved.prompt_text` como fallback deve permanecer indefinidamente ou somente durante uma janela de migração documentada?
- Os serviços consumidores precisam expor `clinical_facts` em observabilidade interna, mesmo sem alterar o contrato HTTP externo?
