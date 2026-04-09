# form-guidance-standard Specification

## Purpose
TBD - created by archiving change cr-ux-003-form-standardization. Update Purpose after archive.
## Requirements
### Requirement: Formulários MUST reutilizar os resumos e agrupamentos canônicos já existentes
Formulários longos ou distribuídos por seções DEVEM (MUST) reutilizar os componentes compartilhados já padronizados para agrupamento e resumo, em vez de criar uma segunda família paralela de widgets.

#### Scenario: Submissão with multiple errors
- **WHEN** o usuário clica no botão "Enviar" com 3 campos obrigatórios vazios
- **THEN** o sistema exibe o resumo canônico de formulário no topo da página ou seção
- **AND** lista os campos que precisam de atenção.

### Requirement: Campos estruturados MUST usar formatadores e normalização compartilhados
Campos com formatos estruturados (CPF, Telefone, CEP, Data) DEVEM (MUST) usar formatadores, restrições e normalização compartilhados no design system.

#### Scenario: Filling in a date
- **WHEN** o usuário preenche um campo de data suportado pelo padrão compartilhado
- **THEN** o sistema orienta e formata a entrada segundo o padrão `DD/MM/AAAA`
- **AND** valida o valor normalizado antes do envio

#### Scenario: Filling in CPF or CEP
- **WHEN** o usuário preenche um campo estruturado como CPF ou CEP
- **THEN** o sistema restringe e normaliza a entrada segundo o helper compartilhado definido para esse tipo
- **AND** o valor enviado ao backend permanece no formato esperado pela API

### Requirement: Localização em Português Brasileiro (pt-BR)
Todo o conteúdo textual apresentado ao usuário, incluindo rótulos de campos (labels), mensagens de erro, textos de ajuda e avisos, DEVE (MUST) estar em Português Brasileiro seguindo rigorosamente as normas gramaticais, incluindo o uso correto de acentuação (ex: "atenção", não "atencao").

#### Scenario: Checking accentuation in error messages
- **WHEN** uma mensagem de erro ou aviso é exibida ao usuário
- **THEN** o texto DEVE conter todos os acentos e caracteres especiais (cedilha, til) conforme a norma culta do pt-BR.

### Requirement: Orientação de Campos Obrigatórios
Campos obrigatórios DEVEM (MUST) ser claramente marcados com um asterisco (*) e os grupos de campos relacionados DEVEM (MUST) ter cabeçalhos descritivos.

#### Scenario: Viewing a long form
- **WHEN** o usuário acessa uma seção do Builder
- **THEN** todos os campos obrigatórios exibem o símbolo '*' ao lado do rótulo
- **AND** campos relacionados (como endereço) estão agrupados sob o título "Endereço".

### Requirement: Formulários administrativos longos MUST preservar progresso
Formulários administrativos longos incluídos neste change DEVEM (MUST) expor estados visíveis de rascunho e restaurar progresso quando isso evitar retrabalho relevante.

#### Scenario: Long editing interrupted in Builder
- **WHEN** o usuário altera um formulário administrativo longo e sai da tela antes da publicação final
- **THEN** o sistema preserva o rascunho conforme a estratégia definida para aquele fluxo
- **AND** exibe um estado claro como "alterações não salvas" ou "rascunho salvo"

