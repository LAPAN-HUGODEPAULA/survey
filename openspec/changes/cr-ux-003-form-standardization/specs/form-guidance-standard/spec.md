## ADDED Requirements

### Requirement: Resumo de Erros Form-Level
Formulários com múltiplas falhas de validação DEVEM exibir um resumo de erros no topo da página ou da seção, além das mensagens inline nos campos.

#### Scenario: Submissão com múltiplos erros
- **WHEN** o usuário clica no botão "Enviar" com 3 campos obrigatórios vazios
- **THEN** o sistema exibe um banner no topo com o título "Há campos que precisam de correção."
- **AND** lista os campos que precisam de atenção.

### Requirement: Máscaras de Entrada e Formatação
Campos com formatos estruturados (CPF, Telefone, CEP, Data) DEVEM utilizar máscaras de entrada automáticas.

#### Scenario: Preenchimento de CPF
- **WHEN** o usuário digita 11 dígitos no campo de CPF
- **THEN** o sistema aplica automaticamente a formatação 000.000.000-00.

### Requirement: Localização em Português Brasileiro (pt-BR)
Todo o conteúdo textual apresentado ao usuário, incluindo rótulos de campos (labels), mensagens de erro, textos de ajuda e avisos, DEVE estar em Português Brasileiro seguindo rigorosamente as normas gramaticais, incluindo o uso correto de acentuação (ex: "atenção", não "atencao").

#### Scenario: Verificar acentuação em mensagens de erro
- **WHEN** uma mensagem de erro ou aviso é exibida ao usuário
- **THEN** o texto DEVE conter todos os acentos e caracteres especiais (cedilha, til) conforme a norma culta do pt-BR.

### Requirement: Orientação de Campos Obrigatórios
Campos obrigatórios DEVEM ser claramente marcados com um asterisco (*) e os grupos de campos relacionados DEVEM ter cabeçalhos descritivos.

#### Scenario: Visualização de formulário longo
- **WHEN** o usuário acessa uma seção do Builder
- **THEN** todos os campos obrigatórios exibem o símbolo '*' ao lado do rótulo
- **AND** campos relacionados (como endereço) estão agrupados sob o título "Endereço".
