## ADDED Requirements

### Requirement: A plataforma MUST usar um único ciclo de validação para formulários estruturados
Todos os formulários estruturados migrados DEVEM (MUST) seguir o mesmo ciclo de validação para reduzir inconsistência entre apps e evitar erros hostis prematuros.

#### Scenario: Campo pristine durante a primeira digitação
- **WHEN** o usuário começa a digitar em um campo ainda não validado
- **THEN** o sistema NÃO DEVE exibir erro de "campo obrigatório" nem de formato incompleto durante essa primeira digitação

#### Scenario: Campo touched ao perder o foco
- **WHEN** o usuário sai de um campo obrigatório ou estruturado
- **THEN** o sistema DEVE validar esse campo no `blur`
- **AND** exibir a mensagem inline se houver erro

#### Scenario: Submissão de formulário com falhas
- **WHEN** o usuário tenta continuar ou enviar um formulário com campos inválidos
- **THEN** o sistema DEVE validar todos os campos relevantes naquele momento
- **AND** exibir mensagens inline
- **AND** exibir um resumo de formulário quando houver múltiplas falhas ou erros distribuídos por mais de uma seção

#### Scenario: Revalidação eficiente após erro visível
- **WHEN** um campo já foi marcado como inválido e o usuário volta a editá-lo
- **THEN** o sistema PODE revalidar esse campo durante as edições seguintes
- **AND** NÃO DEVE revalidar continuamente campos ainda pristine ou nunca expostos como inválidos

### Requirement: Mensagens de Erro Informativas
As mensagens de erro em nível de campo DEVEM (MUST) ser claras, objetivas e indicar a ação corretiva necessária.

#### Scenario: Data format error
- **WHEN** o usuário insere uma data no formato inválido
- **THEN** o sistema exibe "Use o formato DD/MM/AAAA." em vez de "Valor inválido."

### Requirement: O padrão de validação MUST viver no design system
Os comportamentos de `pristine`, `touched`, `submitted` e revalidação DEVEM (MUST) ser centralizados no `packages/design_system_flutter` para evitar implementação divergente por aplicativo.

#### Scenario: Two apps use the same shared field
- **WHEN** `survey-patient` e `survey-frontend` usam a mesma superfície de campo compartilhada
- **THEN** ambos DEVEM herdar o mesmo momento de validação e o mesmo comportamento de apresentação de erro
