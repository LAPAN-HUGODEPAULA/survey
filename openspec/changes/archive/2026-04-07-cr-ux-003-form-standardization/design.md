## Context

A plataforma LAPAN já possui componentes compartilhados que resolvem parte do problema: `DsValidationSummary` para resumo de erros, `DsSection` para agrupamento visual, `DsFieldChrome` para orientação de campo e algumas superfícies de formulário compartilhadas em `packages/design_system_flutter`. Os formulários demográficos de `survey-patient` e `survey-frontend` já usam parte dessa base.

O problema atual é de padronização comportamental, não de ausência total de primitives. Ainda existem diferenças entre:

- quando um erro aparece pela primeira vez;
- quando ele é revalidado;
- como campos estruturados são formatados ou normalizados;
- como formulários longos preservam progresso;
- quando um erro aparece inline, em resumo de topo ou indevidamente em snackbar.

## Goals / Non-Goals

**Goals:**
- Centralizar no `design_system_flutter` um único ciclo de validação para formulários estruturados.
- Evoluir os componentes já existentes (`DsValidationSummary`, `DsSection`, `DsFieldChrome` e widgets de campo compartilhados) em vez de criar equivalentes paralelos.
- Padronizar formatadores e orientação de entrada para CPF, telefone, CEP e data com base na abordagem já utilizada no código.
- Tornar previsível quando usar erro inline, resumo de formulário e mensagens de orientação.
- Introduzir preservação de rascunho e estados de progresso salvo em formulários administrativos longos.

**Non-Goals:**
- Reescrever todos os formulários da plataforma em um único turno (será uma transição incremental).
- Implementar validação no lado do servidor (foco exclusivo em UX do cliente).
- Padronizar entradas conversacionais livres do chat em `clinical-narrative`; esse comportamento exige uma proposta separada.

## Decisions

### 1. Reutilizar e expandir as superfícies já padronizadas
- **Rationale**: `cr-ux-001` já estabeleceu componentes compartilhados para feedback e seções. Criar `DsErrorSummary` ou `DsFormSection` agora duplicaria responsabilidades e aumentaria o custo de manutenção.
- **Implementation**: Expandir `DsValidationSummary` para suportar melhor resumos de formulário e, quando necessário, navegação até o campo; usar `DsSection` e `DsFieldChrome` como base para agrupamento e orientação.

### 2. Um único ciclo de validação: validação adiada
- **Rationale**: Precisamos de um padrão único, previsível, eficiente e amigável. Validar todos os campos durante cada digitação é ruidoso e custa mais; validar só no submit atrasa correções simples demais.
- **Implementation**:
  - Campo `pristine`: nenhum erro durante a digitação inicial.
  - Campo `touched`: validar ao perder o foco (`blur`).
  - Formulário submetido: validar todos os campos e exibir inline + `DsValidationSummary`.
  - Campo já marcado como inválido: revalidar apenas aquele campo durante edições seguintes para remover ou atualizar o erro rapidamente.
- **Result**: Um único modelo serve para todos os formulários estruturados, reduz validações desnecessárias e evita erro hostil prematuro.

### 3. Manter a estratégia atual de formatação e compartilhá-la melhor
- **Rationale**: O código já usa `TextInputFormatter`, normalização e validação local para data, telefone, CEP e CPF. Antes de adicionar `mask_text_input_formatter`, precisamos provar uma limitação real do que já funciona.
- **Implementation**: Extrair e compartilhar formatadores, normalizadores e helpers já usados nos fluxos atuais, em vez de introduzir uma dependência nova neste change.

### 4. Preservação de progresso apenas onde o custo de retrabalho é alto
- **Rationale**: Nem todo formulário precisa de rascunho salvo. O maior ganho está nos formulários administrativos longos do `survey-builder`.
- **Implementation**: Aplicar estados de "alterações não salvas", "rascunho salvo" e restauração de progresso nos formulários administrativos longos explicitamente incluídos no escopo.

### 5. Escopo explícito para `clinical-narrative`
- **Rationale**: Formularios estruturados e entradas conversacionais livres têm necessidades diferentes. Misturar os dois enfraqueceria a proposta.
- **Implementation**: Esta mudança cobre formulários estruturados compartilhados ou equivalentes em `clinical-narrative`; o composer do chat e entradas livres ficam fora do escopo.

## Risks / Trade-offs

- **[Risco]** Alguns formulários atuais dependem de comportamentos locais de validação e podem quebrar ao migrar. → **Mitigação**: Introduzir helpers compartilhados e migrar por superfícies piloto antes de expandir.
- **[Trade-off]** Não adicionar uma biblioteca externa de máscaras pode exigir mais disciplina na manutenção de formatadores internos. → **Mitigação**: concentrar os formatadores compartilhados no design system e cobri-los com testes.
- **[Trade-off]** Preservação de rascunho adiciona estado a formulários administrativos. → **Mitigação**: limitar a feature aos formulários longos de maior custo cognitivo e definir critérios claros para restauração.
