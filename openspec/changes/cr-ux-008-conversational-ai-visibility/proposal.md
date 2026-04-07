## Why

Atualmente, o aplicativo `clinical-narrative` apresenta os estados da IA (sessão, voz, análise) de forma fragmentada através de diversos chips e indicadores, utilizando rótulos técnicos como `analysisPhase=intake`. Isso dificulta a compreensão do usuário sobre o que o sistema está fazendo no momento e reduz a percepção de controle sobre o fluxo da conversa clínica.

## What Changes

- Unificação dos estados de IA em uma única área de "status do assistente" com linguagem humanizada.
- Tradução de rótulos técnicos internos (ex: `intake`, `assessment`) para termos clínicos amigáveis em pt-BR.
- Introdução de controles explícitos para cancelar, tentar novamente ou continuar manualmente durante o processamento de IA.
- Padronização de painéis de insights em cartões tipados com ícones e severidade consistentes.
- Distinção clara entre sugestões da IA, hipóteses, avisos e saídas de documentos confirmadas.

## Capabilities

### New Capabilities
- `conversational-ai-state-visibility`: Define o modelo de visibilidade unificado para o assistente de IA, incluindo a tradução de fases lógicas para termos humanos.
- `ai-insight-panel-standard`: Define os padrões visuais e semânticos para a exibição de insights gerados por IA durante a narrativa clínica.

### Modified Capabilities
- `clinical-chat-ui`: Atualização da interface de chat para acomodar a nova área de status e controles de processamento.
- `clinical-session-ui`: Atualização da interface de sessão para integrar os novos painéis de insights padronizados.

## Impact

- `packages/design_system_flutter`: Novos componentes para painéis de insights e indicadores de status de assistente.
- `apps/clinical-narrative`: Refatoração completa da tela de chat e de sessão clínica para adotar os novos padrões de visibilidade e controle.
