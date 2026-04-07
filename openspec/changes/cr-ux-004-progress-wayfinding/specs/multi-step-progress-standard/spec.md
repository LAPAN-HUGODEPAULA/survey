## ADDED Requirements

### Requirement: Visualização de Etapas Nomeadas
Todo fluxo com mais de duas etapas DEVE (MUST) exibir o nome da etapa atual e a lista das etapas do fluxo, identificando estados de conclusão.

#### Scenario: Visualização de progresso no questionário
- **WHEN** o usuário está na etapa "Instruções" de um questionário
- **THEN** o sistema exibe uma trilha (stepper) mostrando "Aviso" (concluído), "Instruções" (atual) e "Perguntas" (futuro)
- **AND** utiliza o idioma Português Brasileiro (pt-BR)

### Requirement: Indicador de Progresso Textual e Visual
O progresso DEVE (MUST) ser comunicado através de texto (ex: "Passo 2 de 5") em conjunto com uma representação visual (ex: barra de progresso ou trilha).

#### Scenario: Atualizar progresso ao mudar de etapa
- **WHEN** o usuário completa a primeira etapa e avança
- **THEN** o texto de progresso e o preenchimento visual da barra de progresso DEVEM ser atualizados simultaneamente

### Requirement: Integração com Estado de Rascunho e Validação
Os indicadores de progresso DEVEM (MUST) refletir o estado de submissão e rascunho de cada etapa (conforme `cr-ux-003`).

#### Scenario: Etapa com rascunho salvo
- **WHEN** uma etapa possui dados salvos como rascunho no backend
- **THEN** o indicador visual daquela etapa DEVE mostrar um estado de "rascunho" ou "parcialmente preenchido"

#### Scenario: Etapa com erro de validação
- **WHEN** o usuário tenta avançar e uma etapa possui erros pendentes
- **THEN** o indicador visual daquela etapa DEVE mostrar um estado de "erro" ou "atenção" usando o modelo de feedback compartilhado (`cr-ux-001`).

### Requirement: Controle e Retorno do Usuário
O usuário DEVE (MUST) ser capaz de retornar a etapas anteriores do fluxo sem perda dos dados já inseridos, exceto quando o fluxo for transacional e finalizado.

#### Scenario: Voltar para revisar resposta
- **WHEN** o usuário clica no botão "Voltar" de uma etapa
- **THEN** o sistema exibe a etapa anterior com os dados preenchidos preservados
