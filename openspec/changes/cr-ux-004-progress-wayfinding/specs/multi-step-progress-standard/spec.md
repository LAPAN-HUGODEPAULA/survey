## ADDED Requirements

### Requirement: Visualização de Etapas Nomeadas
Todo fluxo com mais de duas etapas DEVE exibir o nome da etapa atual e a lista das etapas do fluxo, identificando estados de conclusão.

#### Scenario: Visualizar progresso no questionário
- **WHEN** o usuário está na etapa "Instruções" de um questionário
- **THEN** o sistema exibe uma trilha (stepper) mostrando "Aviso" (concluído), "Instruções" (atual) e "Perguntas" (futuro)
- **AND** utiliza o idioma Português Brasileiro (pt-BR)

### Requirement: Indicador de Progresso Textual e Visual
O progresso DEVE ser comunicado através de texto (ex: "Passo 2 de 5") em conjunto com uma representação visual (ex: barra de progresso ou trilha).

#### Scenario: Atualizar progresso ao mudar de etapa
- **WHEN** o usuário completa a primeira etapa e avança
- **THEN** o texto de progresso e o preenchimento visual da barra de progresso DEVEM ser atualizados simultaneamente

### Requirement: Controle e Retorno do Usuário
O usuário DEVE ser capaz de retornar a etapas anteriores do fluxo sem perda dos dados já inseridos, exceto quando o fluxo for transacional e finalizado.

#### Scenario: Voltar para revisar resposta
- **WHEN** o usuário clica no botão "Voltar" de uma etapa
- **THEN** o sistema exibe a etapa anterior com os dados preenchidos preservados
