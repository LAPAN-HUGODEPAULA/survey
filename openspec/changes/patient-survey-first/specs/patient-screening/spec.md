# Especificação para Triagem de Pacientes

## ADDED Requirements

### Requirement: Acesso ao Questionário de Triagem de 7 Perguntas
O sistema MUST permitir que pacientes não autenticados iniciem o questionário de triagem de 7 perguntas através do aplicativo `survey-patient`.

#### Cenário: Paciente acessa o questionário

**Dado** que um paciente não autenticado acessa o aplicativo `survey-patient`
**Quando** ele navega para a página inicial do questionário
**Então** ele deve visualizar a primeira pergunta do questionário de 7 perguntas

### Requirement: Preenchimento do Questionário de Triagem de 7 Perguntas
O sistema MUST garantir que os pacientes possam completar todas as 7 perguntas do questionário e que suas respostas sejam coletadas.

#### Cenário: Paciente preenche o questionário com sucesso

**Dado** que um paciente está respondendo ao questionário de 7 perguntas
**Quando** ele responde a todas as perguntas
**Então** as respostas devem ser coletadas e armazenadas temporariamente

### Requirement: Exibição de Resumo Simplificado
O sistema MUST apresentar um resumo conciso das respostas do paciente após a conclusão do questionário, juntamente com uma recomendação para buscar orientação profissional.

#### Cenário: Paciente visualiza o resumo após o questionário

**Dado** que um paciente concluiu o questionário de 7 perguntas
**Quando** ele avança para a tela final
**Então** ele deve visualizar um resumo simplificado de suas respostas e um incentivo para buscar ajuda profissional
