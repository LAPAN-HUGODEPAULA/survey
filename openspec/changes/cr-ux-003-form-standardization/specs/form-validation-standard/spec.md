## ADDED Requirements

### Requirement: Tempo de Validação de Campo
A validação de campos individuais DEVE ocorrer apenas quando o campo perde o foco (blur) ou quando o formulário é submetido, evitando o disparo de erros durante a digitação inicial.

#### Scenario: Validação ao perder o foco
- **WHEN** o usuário digita um valor inválido em um campo obrigatório
- **AND** move o foco para outro campo
- **THEN** o sistema exibe a mensagem de erro específica para aquele campo

#### Scenario: Sem erro prematuro durante digitação
- **WHEN** o usuário começa a digitar em um campo vazio
- **THEN** o sistema NÃO DEVE exibir erros de "campo obrigatório" ou "formato inválido" até que o foco seja removido

### Requirement: Mensagens de Erro Informativas
As mensagens de erro em nível de campo DEVEM ser claras, objetivas e indicar a ação corretiva necessária.

#### Scenario: Erro de formato de data
- **WHEN** o usuário insere uma data no formato inválido
- **THEN** o sistema exibe "Use o formato DD/MM/AAAA." em vez de "Valor inválido."
