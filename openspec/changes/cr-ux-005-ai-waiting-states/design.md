## Context

Atualmente, o LAPAN Survey Platform utiliza `DsLoading` para operações de IA. O tempo de resposta da IA pode ser superior a 10 segundos, o que gera ansiedade sem feedback de estágio. O grafo de execução da IA (LangGraph) já possui estágios lógicos, mas estes não são expostos ao frontend.

## Goals / Non-Goals

**Goals:**
- Implementar um indicador de progresso rico que exiba estágios e mensagens de valor.
- Criar um contrato de API para reporte de estágios de IA.
- Melhorar a percepção de utilidade e confiabilidade da IA durante a espera.

**Non-Goals:**
- Implementar streaming de texto real-time (foco em estágios de processamento).
- Alterar a lógica clínica dos agentes de IA.

## Decisions

### 1. Novo Componente: `DsAIProgressIndicator`
- **Rationale**: `DsLoading` é genérico demais para esperas de longa duração.
- **Implementation**: Um widget que recebe um `currentStage` e mapeia para rótulos e mensagens de reasseguramento. Incluirá animações suaves para transição de estágios.

### 2. Padrão de Reporte de Estágios (Backend)
- **Rationale**: A IA opera em múltiplas fases (LangGraph).
- **Implementation**: O `clinical-writer-api` enviará atualizações de estado para o `survey-backend` (ou o frontend consultará via polling). Utilizaremos um modelo de "estágios nomeados" padronizado entre os serviços.

### 3. Microcopy em pt-BR com Reasseguramento
- **Rationale**: A linguagem deve reduzir a ansiedade clínica.
- **Microcopy Mapping**:
  - `received`: "Recebemos suas informações."
  - `validating`: "Estamos organizando os dados antes de montar a resposta."
  - `analyzing`: "Estamos analisando os sinais principais do caso para uma leitura inicial mais cuidadosa."
  - `drafting`: "Estamos escrevendo a primeira versão do documento."
  - `reviewing`: "Estamos revisando o conteúdo para entregar algo mais claro e confiável."
  - `formatting`: "Estamos preparando a apresentação final."

## Risks / Trade-offs

- **[Risco]** Latência adicional para polling de status. → **Mitigação**: O polling será leve e apenas para estágios principais.
- **[Trade-off]** Complexidade de gerenciar estados assíncronos no frontend. → **Mitigação**: Utilizar o `DsFlowState` ou padrões de `StreamBuilder` para simplificar a UI.
