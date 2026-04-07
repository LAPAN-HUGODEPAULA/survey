## ADDED Requirements

### Requirement: Área de Status Unificada do Assistente
O sistema DEVE expor uma única área de status ("Status do Assistente") que consolide todos os estados de processamento de IA (voz, transcrição, análise).

#### Scenario: Visualizar status durante a conversa
- **WHEN** a IA está processando a entrada de voz do clínico
- **THEN** o sistema exibe um indicador de status unificado com a fase atual e uma animação discreta de atividade
- **AND** utiliza o idioma Português Brasileiro (pt-BR)

### Requirement: Humanização de Fases Técnicas
O sistema DEVE traduzir as fases técnicas internas (`analysisPhase`) para termos clínicos humanizados em pt-BR.

#### Scenario: Tradução de fases internas
- **WHEN** a fase interna for `intake` -> **THEN** o sistema exibe "Organizando a anamnese"
- **WHEN** a fase interna for `assessment` -> **THEN** o sistema exibe "Analisando sinais clínicos"
- **WHEN** a fase interna for `plan` -> **THEN** o sistema exibe "Estruturando o plano"
- **WHEN** a fase interna for `wrap_up` -> **THEN** o sistema exibe "Preparando o encerramento"

### Requirement: Controle do Usuário sobre Processamento de IA
O sistema DEVE fornecer controles visíveis para que o usuário possa intervir no processamento de IA quando houver atrasos ou falhas.

#### Scenario: Cancelar análise em andamento
- **WHEN** uma análise de IA está sendo gerada
- **THEN** o sistema exibe um botão de "Cancelar" ou "Continuar manualmente" visível na área de status
