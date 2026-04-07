## MODIFIED Requirements

### Requirement: AI Processing Error Handling
O sistema DEVE tratar falhas de geração e análise de IA com mensagens claras em pt-BR e distinguir erros transientes (retryable) de permanentes.

#### Scenario: Falha transiente de IA
- **WHEN** ocorre uma falha temporária no processamento de IA (ex: timeout)
- **THEN** o sistema exibe "Não foi possível concluir agora. Tente novamente em alguns instantes." e oferece um botão de `Tentar Novamente`

#### Scenario: Falha persistente de IA
- **WHEN** a IA falha repetidamente ou devido a um erro de conteúdo (ex: dados insuficientes)
- **THEN** o sistema exibe "Não conseguimos gerar a análise automática para este caso." e permite continuar manualmente ou submeter sem o laudo de IA

### Requirement: AI Partial Results Handling
O sistema DEVE permitir que o usuário utilize resultados parciais ou acesse os dados originais quando o processamento total de IA não for concluído.

#### Scenario: Acesso aos dados originais após falha de IA
- **WHEN** a geração do laudo de IA falha
- **THEN** o sistema garante que o usuário ainda possa visualizar e baixar as respostas do questionário
