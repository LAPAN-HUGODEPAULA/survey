## Context

A plataforma LAPAN já possui o enum `DsStatusType` (`neutral`, `info`, `success`, `warning`, `error`) no `packages/design_system_flutter`, mas seu uso é fragmentado. Atualmente, muitos fluxos dependem de `ScaffoldMessenger.of(context).showSnackBar()` com textos simples, sem taxonomia visual ou semântica.

## Goals / Non-Goals

**Goals:**
- Centralizar o comportamento de feedback visual e semântico no design system.
- Criar componentes padronizados para `Banner`, `InlineMessage`, `Toast` e `Dialog`.
- Implementar regras de mapeamento de severidade para ícones e cores conforme o plano de UI/UX.

**Non-Goals:**
- Substituir todas as instâncias de `SnackBar` no sistema em um único turno (será incremental).
- Implementar notificações push (foco em UI in-app).

## Decisions

### 1. Modelo de Dados `DsFeedbackModel`
- **Rationale**: Ter um contrato único para mensagens facilita a reutilização entre diferentes tipos de contêineres (banner, snackbar, diálogo).
- **Implementation**: Classe contendo `severity`, `title`, `body`, `icon`, `primaryAction`, `secondaryAction`.

### 2. Componentes de UI Baseados em Severidade
- **Rationale**: Garantir que o usuário identifique o tipo de mensagem instantaneamente pela cor e ícone, sem depender apenas do texto.
- **Mapping**:
  - `info` -> `Icons.info_outline` / Azul
  - `success` -> `Icons.check_circle_outline` / Verde
  - `warning` -> `Icons.warning_amber_rounded` / Âmbar
  - `error` -> `Icons.error_outline` / Vermelho

### 3. Substituição Gradual de `SnackBar` por `DsToast`
- **Rationale**: `DsToast` será um wrapper sobre o `SnackBar` nativo do Flutter, mas com suporte embutido ao `DsFeedbackModel`, garantindo que toda notificação transiente siga o padrão visual.

### 4. Componente `DsDialog` de Confirmação
- **Rationale**: Diálogos devem ser usados com moderação e exigir verbos explícitos ("Excluir", "Salvar") em vez de "Sim/Não" ou "OK/Cancelar" genéricos.

## Risks / Trade-offs

- **[Risco]** Sobrecarga visual se muitos banners forem usados simultaneamente. → **Mitigação**: Limitar a um banner por página ou usar um sistema de pilha (stack).
- **[Trade-off]** Refatoração de snackbars existentes pode ser trabalhosa. → **Mitigação**: Manter compatibilidade com `SnackBar` mas encorajar o uso do novo `DsToast`.
