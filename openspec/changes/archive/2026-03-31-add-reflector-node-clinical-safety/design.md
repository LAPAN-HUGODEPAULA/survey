## Context

O `clinical-writer-api` já separa o pipeline em `ContextLoader`, `ClinicalAnalyzer` e `PersonaWriter`, mas ainda entrega o laudo final imediatamente após a escrita. Isso deixa sem enforcement um requisito já implícito na arquitetura multiagente do projeto: a existência de um nó de crítica capaz de validar segurança clínica, aderência ao destinatário e grounding do texto antes da resposta final.

As principais restrições deste desenho são:
- o endpoint `POST /process` deve continuar externamente compatível com os serviços FastAPI atuais;
- o loop de reflexão não pode introduzir recursão ilimitada nem latência sem limite;
- o nó de crítica precisa aplicar critérios mínimos obrigatórios mesmo quando o perfil de saída não for médico;
- o custo adicional de reflexão deve ser concentrado em um modelo superior, sem reconfigurar os nós de análise e escrita.

Stakeholders principais:
- equipe do `clinical-writer-api`, responsável pelo grafo e pela segurança do laudo;
- consumidores FastAPI que dependem do contrato atual de `ProcessResponse`;
- clínicos, pesquisadores e destinatários não-médicos, como escolas e familiares, que exigem tom apropriado e ausência de instruções clínicas indevidas.

## Goals / Non-Goals

**Goals:**
- Inserir `ReflectorNode` como quarta etapa obrigatória após `PersonaWriter` para revisar o laudo antes da finalização.
- Fazer o `ReflectorNode` operar como um "Juiz IA" usando um modelo superior de crítica, configurável separadamente dos modelos de análise e escrita.
- Definir um contrato explícito no estado para feedback corretivo, status de reflexão e contador de iterações.
- Exigir validação mínima de tom adequado ao destinatário e de ausência de recomendações médicas invasivas em laudos não-médicos.
- Encaminhar falhas de reflexão de volta ao `PersonaWriter` com feedback estruturado, até um número máximo de 2 iterações corretivas.
- Encerrar com erro acionável quando o laudo não convergir após o limite de correções.

**Non-Goals:**
- Redesenhar o payload HTTP do `clinical-writer-api` para expor o parecer completo do juiz no contrato externo.
- Implementar revisão humana, filas assíncronas ou checkpoint persistente neste change.
- Introduzir novas coleções MongoDB para armazenar histórico de reflexão.
- Tornar o `ReflectorNode` responsável por reanalisar o conteúdo clínico bruto; a função dele é julgar a saída do writer, não substituir o analyzer.

## Decisions

### Decision: Modelar a reflexão como uma etapa explícita de estado e não como validação embutida no Writer

O `ReflectorNode` será um nó distinto no `StateGraph`, executado sempre após o `PersonaWriter`. Ele lerá `report`, `draft_narrative`, `clinical_facts`, `output_profile` e metadados de audiência, e produzirá um veredito estruturado no estado, por exemplo: `reflection_status`, `reflection_feedback`, `reflection_iteration`, `reflection_decision`.

Rationale:
- mantém separação clara entre geração e julgamento;
- torna o ciclo Writer→Reflector observável e testável;
- evita que o writer silencie seu próprio erro ou "auto-aprove" um laudo inseguro.

Alternative considered:
- adicionar validações de segurança diretamente no `PersonaWriter`.
  - rejeitado porque mistura produção e revisão, reduzindo rastreabilidade e dificultando testes do laço de correção.

### Decision: Usar um modelo superior dedicado para o `ReflectorNode`

O `ReflectorNode` deve usar um modelo de crítica explicitamente configurado, como `GPT-4o` ou equivalente superior, separado dos modelos usados pelo `ClinicalAnalyzer` e `PersonaWriter`. O contrato do grafo deve permitir injeção desse modelo por dependência ou factory sem quebrar `create_graph(...)`.

Rationale:
- a crítica exige mais confiabilidade e julgamento que a escrita inicial;
- concentra custo adicional apenas na etapa de segurança;
- permite testes rápidos com doubles mantendo a produção em modelo mais robusto.

Alternative considered:
- reutilizar o mesmo modelo do writer para crítica.
  - rejeitado porque reduz independência da revisão e enfraquece a barreira de segurança.

### Decision: Formalizar feedback corretivo estruturado e no máximo 2 iterações corretivas

Quando a reflexão falhar, o nó deve devolver feedback estruturado ao `PersonaWriter` contendo pelo menos: motivo da reprovação, critério violado e instrução de correção. O grafo permitirá no máximo 2 reescritas acionadas pela reflexão. Após isso, o fluxo deve encerrar com erro acionável, em vez de loop infinito ou aprovação forçada.

Rationale:
- fixa um limite previsível de latência e custo;
- transforma a crítica em entrada objetiva para a reescrita;
- evita loops infinitos em prompts ou perfis difíceis de satisfazer.

Alternative considered:
- permitir número indefinido de revisões até obter PASS.
  - rejeitado porque torna o sistema não determinístico e pode gerar custo/latência descontrolados.

### Decision: Tratar laudos não-médicos como perfis com política de segurança reforçada

Perfis como `school_report`, `educational_support_summary`, `parental_guidance` e equivalentes não-médicos devem ativar validação reforçada contra prescrições, diagnósticos prescritivos ou recomendações invasivas. Em caso de violação, o `ReflectorNode` deve obrigatoriamente reprovar o laudo e instruir correção.

Rationale:
- o risco de dano é maior quando um destinatário não-médico recebe linguagem prescritiva;
- torna testável a regra do cenário escolar exigido pelo change;
- alinha a revisão com a semântica do perfil de saída já presente no estado.

Alternative considered:
- aplicar exatamente a mesma rubrica para todos os perfis.
  - rejeitado porque não captura o risco específico de audiência e enfraquece a política de segurança.

### Decision: Preservar o contrato externo do `/process` e expor falha de convergência apenas como erro acionável

O endpoint continuará retornando `ProcessResponse` sem novos campos obrigatórios. Quando a reflexão falhar definitivamente, o serviço deve responder com erro acionável compatível com a trilha atual de falhas internas, em vez de retornar um laudo inseguro ou um payload parcialmente aprovado.

Rationale:
- evita breaking change para consumidores atuais;
- mantém a barreira de segurança dentro da implementação do grafo;
- impede entrega de relatório inseguro em caso de não convergência.

Alternative considered:
- sempre retornar o último draft com warnings.
  - rejeitado porque normaliza entrega de conteúdo reprovado pelo juiz.

## Risks / Trade-offs

- [Risco] A reflexão aumentar latência percebida no `/process`. → Mitigação: limitar para 2 iterações corretivas e usar modelo superior apenas no nó de crítica.
- [Risco] O feedback do juiz ser vago e não ajudar o writer a convergir. → Mitigação: exigir payload estruturado com critério violado e instrução explícita de correção.
- [Risco] Classificação incorreta de perfil não-médico deixar passar conteúdo invasivo. → Mitigação: mapear perfis sensíveis no design e cobrir com testes de contrato.
- [Risco] Laudos legítimos de perfil médico serem bloqueados por regra excessivamente rígida. → Mitigação: condicionar a regra de proibição invasiva ao tipo de audiência/perfil de saída.
- [Risco] O loop de correção modificar fatos clínicos em vez de apenas reformular a narrativa. → Mitigação: manter `clinical_facts` como fonte clínica imutável e permitir ao writer alterar apenas o laudo.

## Migration Plan

1. Adicionar os delta specs para topologia do grafo, geração de documentos e reflexão clínica.
2. Expandir `AgentState` com campos de reflexão, contador de iterações e feedback corretivo.
3. Implementar `ReflectorNode` e a aresta condicional `PersonaWriter` → `ReflectorNode` → (`END` ou `PersonaWriter`/erro).
4. Introduzir configuração do modelo superior de crítica preservando a assinatura pública de `create_graph(...)`.
5. Atualizar testes unitários e de contrato para cenários de PASS, FAIL com correção e FAIL por exceder limite.
6. Implantar sem mudança de contrato externo; rollback consiste em remover a etapa de reflexão e restaurar a topologia anterior.

## Open Questions

- O erro de não convergência após 2 iterações deve usar um `error_kind` novo específico, como `reflection_failed`, ou reutilizar uma categoria genérica de geração?
- O feedback do `ReflectorNode` deve ser persistido apenas em logs/observabilidade interna ou também em auditoria estruturada futura?
