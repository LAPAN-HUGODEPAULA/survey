## Context

A plataforma LAPAN possui formulários em quatro aplicativos distintos. Atualmente, cada aplicativo lida com validação de forma ligeiramente diferente. Alguns campos usam `AutovalidateMode.onUserInteraction` (que pode ser ruidoso durante a digitação inicial), enquanto outros validam apenas no `submit`. Não há um componente padrão para exibir um resumo de erros no topo de formulários longos, resultando em usuários "caçando" erros inline.

## Goals / Non-Goals

**Goals:**
- Centralizar o comportamento de validação no `design_system_flutter`.
- Criar um componente `DsErrorSummary` reutilizável.
- Padronizar o uso de máscaras de entrada (CPF, telefone, CEP, data).
- Fornecer um wrapper de formulário que gerencie o estado de "erros pendentes".

**Non-Goals:**
- Reescrever todos os formulários da plataforma em um único turno (será uma transição incremental).
- Implementar validação no lado do servidor (foco exclusivo em UX do cliente).

## Decisions

### 1. Novo Componente: `DsErrorSummary`
- **Rationale**: Facilitar a navegação em formulários longos e densos (como no `survey-builder`).
- **Implementation**: Um widget que recebe uma lista de erros (nome do campo + mensagem) e permite pular para o campo com erro (via `ScrollController`).

### 2. Validação por "Blur" no Flutter
- **Rationale**: Reduzir o ruído visual ("erro hostil") que ocorre quando o usuário começa a digitar e o sistema já reclama que o campo está incompleto.
- **Implementation**: Utilizar `AutovalidateMode.onUserInteraction` em combinação com um estado interno que controla se o campo já foi "tocado" (touched).

### 3. Máscaras via `mask_text_input_formatter`
- **Rationale**: É o padrão da indústria no ecossistema Flutter para lidar com máscaras complexas.
- **Implementation**: Criar um componente `DsMaskedTextField` que encapsula a lógica do formatter para tipos comuns (CPF, etc.).

### 4. Agrupamento com `DsFormSection`
- **Rationale**: Melhorar o wayfinding visual.
- **Implementation**: Widget de contêiner com título, subtítulo opcional e espaçamento padronizado para campos de entrada.

## Risks / Trade-offs

- **[Risco]** Introdução de quebras em formulários que dependem de comportamentos de validação customizados. → **Mitigação**: O novo padrão será opcional no início, permitindo migração gradual.
- **[Trade-off]** O uso de máscaras pode complicar a extração de valores "crus" para a API (ex: enviar CPF sem pontos). → **Mitigação**: O componente fornecerá um método para obter o valor não formatado.
