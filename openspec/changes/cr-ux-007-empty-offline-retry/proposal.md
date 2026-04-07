## Why

Atualmente, o LAPAN Survey Platform possui estados vazios (empty states) e caminhos de erro que não são suficientemente informativos ou acionáveis. Os usuários muitas vezes encontram telas vazias sem saber o motivo ou se deparam com falhas de conexão que não oferecem uma forma clara de tentar novamente ou entender o impacto em seus dados. Melhorar esses estados é crucial para reduzir o abandono e garantir a confiança no sistema, especialmente em ambientes clínicos com conectividade instável.

## What Changes

- Padronização de estados vazios (empty states) em todos os catálogos e listas (ex: builder, surveys, histórico).
- Implementação de estados offline que expliquem o que ainda funciona e se os dados locais estão seguros.
- Introdução de controles de "Tentar Novamente" (Retry) visíveis e consistentes para falhas de rede ou carregamento.
- Substituição de strings de exceção técnica por mensagens em Português Brasileiro (pt-BR) que expliquem o problema em termos humanos.
- Adição de ações sugeridas em todas as telas de estado vazio para evitar becos sem saída na navegação.

## Capabilities

### New Capabilities
- `empty-state-standard`: Define como o sistema deve se comportar quando não há dados, incluindo explicação do motivo e próxima ação sugerida.
- `offline-retry-experience`: Define os padrões de interface e comportamento para perda de conectividade e recuperação de falhas, focando em reasseguramento e facilidade de tentativa.

### Modified Capabilities
- `error-handling`: Atualização para incluir requisitos de mensagens amigáveis e ações de recuperação (retry) em vez de apenas reportar o erro técnico.

## Impact

- `packages/design_system_flutter`: Novos componentes `DsEmptyState`, `DsOfflineBanner` e atualizações no `DsError`.
- Todos os aplicativos front-end: Refatoração de listas e tratadores de erro para usar os novos padrões.
- `apps/survey-builder`: Melhoria nos catálogos de prompts, personas e questionários.
- `apps/clinical-narrative`: Melhoria no comportamento do chat e transcrição durante instabilidades de rede.
