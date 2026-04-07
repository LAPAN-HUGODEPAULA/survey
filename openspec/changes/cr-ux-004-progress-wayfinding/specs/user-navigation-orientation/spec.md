## ADDED Requirements

### Requirement: Orientação após Redirecionamento
Após um redirecionamento automático entre fluxos ou telas, o sistema DEVE fornecer uma breve explicação visual do novo contexto (ex: "Sucesso! Agora você pode visualizar seu laudo").

#### Scenario: Redirecionamento após salvar questionário
- **WHEN** o usuário clica em "Finalizar" e é redirecionado para a tela de relatório
- **THEN** o sistema exibe um banner ou título transicional: "Respostas registradas. Relatório em preparo."

### Requirement: Wayfinding em Editores e Páginas Longas
Páginas ou editores com múltiplas seções DEVEM oferecer um sumário local ou cabeçalhos persistentes (sticky headers) que ajudem na orientação.

#### Scenario: Edição no Builder
- **WHEN** o usuário edita um questionário longo no `survey-builder`
- **THEN** o sistema fornece uma navegação lateral ou sumário que permite pular para as seções "Detalhes", "Perguntas" e "Persona".

### Requirement: Hierarquia e Contexto de Retorno
O usuário DEVE sempre ter um caminho visual de retorno ao contexto anterior (breadcrumbs ou botão de volta contextual) que não dependa exclusivamente da navegação do navegador.

#### Scenario: Navegar entre telas de configuração
- **WHEN** o usuário entra em uma tela de sub-configuração
- **THEN** o sistema exibe um botão de "Voltar" ou breadcrumbs permitindo retornar à tela pai.
