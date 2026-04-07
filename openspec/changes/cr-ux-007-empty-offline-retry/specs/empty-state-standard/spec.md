## ADDED Requirements

### Requirement: Explicação de Estado Vazio
Toda lista ou tela baseada em dados que não possua conteúdo para exibir DEVE apresentar uma explicação em Português Brasileiro (pt-BR) sobre o motivo da ausência de dados.

#### Scenario: Visualizar catálogo de questionários vazio
- **WHEN** o usuário acessa o catálogo e não há questionários cadastrados
- **THEN** o sistema exibe: "Nenhum questionário encontrado. Crie o primeiro questionário para começar."

### Requirement: Ação Sugerida em Estados Vazios
Toda tela de estado vazio DEVE incluir pelo menos uma ação primária sugerida para que o usuário possa sair do estado de "beco sem saída".

#### Scenario: Criar primeiro item a partir do estado vazio
- **WHEN** o sistema exibe uma tela vazia
- **THEN** o sistema apresenta um botão de ação proeminente (ex: "Novo Questionário", "Cadastrar Paciente").
