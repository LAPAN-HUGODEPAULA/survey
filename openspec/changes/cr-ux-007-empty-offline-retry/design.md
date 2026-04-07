## Context

A plataforma LAPAN já possui o componente `DsError`, mas ele é focado em exibição de erro sem suporte nativo a retry ou mapeamento semântico. Os catálogos de questionários e usuários não possuem um padrão para telas vazias, e o sistema não comunica explicitamente o estado offline ao usuário.

## Goals / Non-Goals

**Goals:**
- Criar componentes padronizados para `Empty State`, `Offline Banner` e `Retry`.
- Centralizar o mapeamento de mensagens de erro técnicas para mensagens em Português Brasileiro amigáveis.
- Implementar suporte global a detecção de conectividade e feedback visual persistente.

**Non-Goals:**
- Implementar sincronização de dados complexa em modo offline (apenas comunicação de estado e reasseguramento).
- Redesenhar todos os componentes de erro existentes em um único turno (será uma migração incremental).

## Decisions

### 1. Novo Componente: `DsEmptyState`
- **Rationale**: Usuários não devem encontrar "buracos negros" na interface sem explicação ou saída.
- **Implementation**: Widget que recebe `icon`, `title`, `description` e `primaryAction`. O microcopy padrão será focado em encorajar o próximo passo (ex: "Criar primeiro...").

### 2. Detecção de Conectividade e `DsOfflineBanner`
- **Rationale**: Em ambientes clínicos, a rede pode oscilar. O usuário precisa saber se suas alterações estão seguras localmente.
- **Implementation**: Utilizar o pacote `connectivity_plus` e expor um stream de estado de conexão no design system. O `DsOfflineBanner` será exibido automaticamente no topo da página quando o estado for `none`.

### 3. Utilitário `DsErrorMapper`
- **Rationale**: Expor "DioError" ou "SocketException" para o usuário final quebra a confiança e o profissionalismo da plataforma.
- **Implementation**: Uma classe utilitária que mapeia exceções comuns e códigos HTTP para strings em pt-BR amigáveis.
- **Exemplo**: `500` -> "O sistema está instável agora. Tente novamente em instantes."

### 4. Suporte a Retry no `DsError`
- **Rationale**: Erros transientes de rede são comuns. Um botão de retry economiza tempo do usuário.
- **Implementation**: Adicionar o callback opcional `onRetry` ao widget `DsError`. Quando presente, o widget exibirá um botão de ação com o texto "Tentar Novamente".

## Risks / Trade-offs

- **[Risco]** Banners persistentes podem ocultar conteúdos ou botões de ação fixos no topo. → **Mitigação**: O `DsScaffold` deve prever o deslocamento do conteúdo quando o banner offline estiver ativo.
- **[Trade-off]** Mapear todos os erros técnicos pode esconder detalhes úteis para suporte. → **Mitigação**: O `DsErrorMapper` continuará logando o erro técnico original no console/crashlytics, mas exibirá apenas a mensagem amigável para o usuário.
