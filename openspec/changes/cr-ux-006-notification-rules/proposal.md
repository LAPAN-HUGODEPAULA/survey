## Why

Atualmente, a plataforma LAPAN utiliza notificações, snackbars e diálogos de forma inconsistente. Eventos que merecem feedback em contexto (inline) ou resumos são muitas vezes comunicados via snackbars efêmeros, o que prejudica a compreensão e a acessibilidade. Estabelecer regras claras de uso para cada tipo de contêiner de mensagem é fundamental para uma experiência de usuário previsível e confiável.

## What Changes

- Definição de regras de uso para `SnackBar`, `Banner`, `InlineMessage` e `Dialog`.
- Padronização de componentes de feedback no design system para suportar o novo modelo de taxonomia (info, success, warning, error).
- Restrição do uso de `SnackBar` apenas para confirmações transientes e ações leves (ex: desfazer).
- Promoção do uso de `Banners` para informações persistentes e `Dialogs` exclusivamente para ações bloqueantes ou destrutivas.

## Capabilities

### New Capabilities
- `platform-feedback-architecture`: Define a hierarquia, o posicionamento e as regras de comportamento para todas as mensagens de feedback do sistema.

### Modified Capabilities
- Nenhuma.

## Impact

- `packages/design_system_flutter`: Atualização e criação de componentes de mensagem (`DsMessageBanner`, `DsInlineMessage`, `DsToast`).
- Todos os aplicativos front-end: Refatoração de fluxos de sucesso, erro e confirmação para seguir os novos padrões.
