## ADDED Requirements

### Requirement: Exibição de Estágios de IA
Todo fluxo que envolva processamento de IA de longa duração (mais de 3 segundos) DEVE exibir o estágio atual do processamento em linguagem humana clara.

#### Scenario: Visualizar estágios no questionário
- **WHEN** o usuário finaliza o questionário e a IA começa a gerar o laudo
- **THEN** o sistema exibe sequencialmente os estágios: "Recebido", "Validando dados", "Analisando sinais", "Escrevendo rascunho", "Revisando conteúdo", "Formatando laudo"
- **AND** utiliza o idioma Português Brasileiro (pt-BR)

### Requirement: Mensagens de Reasseguramento e Valor
Cada estágio de espera de IA DEVE incluir uma mensagem que tranquilize o usuário sobre o progresso e explique o valor do que está sendo feito.

#### Scenario: Reasseguramento durante análise
- **WHEN** o sistema está no estágio "Analisando sinais"
- **THEN** o sistema exibe: "Estamos analisando os sinais principais do caso para uma leitura inicial mais cuidadosa."
- **AND** avisa: "Isso pode levar alguns instantes. Não é preciso refazer a ação."

### Requirement: Preservação de Controle e Contexto
O sistema DEVE permitir que o usuário continue interagindo com informações já disponíveis (leitura de respostas, revisão de histórico) enquanto o processamento de IA ocorre em segundo plano, quando a lógica do negócio permitir.

#### Scenario: Revisão durante geração de laudo
- **WHEN** a IA está gerando um laudo clínico
- **THEN** o sistema mantém a visualização das respostas do questionário disponível para leitura
- **AND** exibe um indicador de progresso discreto mas informativo na tela
