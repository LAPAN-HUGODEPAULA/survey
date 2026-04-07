## Context

A plataforma LAPAN utiliza fluxos multi-etapas em diversos contextos (paciente, profissional, builder). Atualmente, o `DsSurveyProgressIndicator` é o único componente de progresso, mas ele é limitado a uma barra e uma contagem numérica. Não há um padrão para steppers nomeados ou para navegação hierárquica (breadcrumbs), o que prejudica a orientação do usuário em processos longos ou após redirecionamentos.

## Goals / Non-Goals

**Goals:**
- Criar um componente de stepper nomeado (`DsStepper`) reutilizável.
- Implementar suporte a breadcrumbs e navegação de retorno consistente.
- Padronizar o wayfinding em formulários longos através de cabeçalhos persistentes e sumários.
- Melhorar a comunicação de transição entre telas/fluxos.

**Non-Goals:**
- Implementar navegação complexa de "árvore" (foco em fluxos lineares e hierarquia simples).
- Substituir a navegação nativa do navegador (apenas complementá-la com controles in-app).

## Decisions

### 1. Novo Componente: `DsStepper`
- **Rationale**: Usuários precisam saber em qual fase do processo estão, não apenas a porcentagem.
- **Implementation**: Um widget que recebe uma lista de objetos `DsStep` (com label e estado: `todo`, `active`, `done`). Será responsivo, alternando para modo compacto (apenas texto/contagem) em telas pequenas.

### 2. Navegação de Retorno e Breadcrumbs
- **Rationale**: Reduzir a dependência do botão "Voltar" do navegador, que nem sempre preserva o estado do app corretamente no Flutter Web.
- **Implementation**: Criar um widget `DsBreadcrumbs` que mapeia a rota atual para uma trilha clicável. Adicionar um padrão de "Back Button" consistente no `DsScaffold` ou `DsPageHeader`.

### 3. Wayfinding em Editores Longos (Sticky Headers)
- **Rationale**: Em formulários como os do `survey-builder`, o usuário perde o contexto ao rolar a página.
- **Implementation**: Utilizar `SliverStickyHeader` ou padrões de cabeçalho persistente que mostram a seção atual do formulário no topo da área de conteúdo enquanto o usuário rola.

### 4. Modelo de Estado de Fluxo (`DsFlowState`)
- **Rationale**: Centralizar o controle de progresso e garantir que o retorno para etapas anteriores preserve os dados.
- **Implementation**: Uma classe de estado que mantém o `currentStepIndex` e uma lista de `payloads` de dados por etapa.

## Risks / Trade-offs

- **[Risco]** Excesso de informação visual em telas pequenas. → **Mitigação**: O `DsStepper` terá uma versão simplificada para mobile/telas estreitas.
- **[Trade-off]** Manter o estado de múltiplas etapas aumenta a complexidade do gerenciamento de estado local. → **Mitigação**: Utilizar padrões de `ChangeNotifier` ou `Bloc` já estabelecidos no projeto para isolar a lógica do fluxo.
