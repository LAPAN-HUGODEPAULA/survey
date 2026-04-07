## ADDED Requirements

### Requirement: Uso de Snackbars para Confirmações Transientes
Os Snackbars DEVEM ser reservados exclusivamente para confirmações de ações concluídas com sucesso e ações leves que permitam desfazer (undo). Eles não devem ser usados para erros de validação ou informações críticas.

#### Scenario: Confirmação de salvamento
- **WHEN** o usuário salva uma configuração
- **THEN** o sistema exibe um Snackbar transiente: "Alterações salvas."

### Requirement: Uso de Banners para Informações Persistentes
Os Banners DEVEM ser usados para fornecer informações contextuais persistentes, avisos de estado degradado ou riscos clínicos/legais que não interrompem o fluxo atual.

#### Scenario: Aviso de modo offline
- **WHEN** a conexão com o servidor é perdida
- **THEN** o sistema exibe um Banner no topo da página: "Você está offline. Algumas funções podem estar limitadas."

### Requirement: Uso de Diálogos para Ações Bloqueantes
Os Diálogos (Modais) DEVEM ser usados apenas para ações que exijam uma decisão explícita do usuário antes de prosseguir, especialmente em ações destrutivas ou irreversíveis.

#### Scenario: Confirmar exclusão de questionário
- **WHEN** o usuário clica em "Excluir Questionário"
- **THEN** o sistema abre um Diálogo de confirmação com a pergunta e as opções "Excluir" (destrutiva) e "Cancelar".

### Requirement: Erros de Validação Inline
Falhas de validação de formulário DEVEM ser apresentadas de forma inline (próximo ao campo) ou em um resumo de erros, e NUNCA apenas via Snackbar ou Banner global.

#### Scenario: Tentar enviar formulário com erro
- **WHEN** o usuário tenta enviar o formulário com campos obrigatórios vazios
- **THEN** o sistema destaca os campos com erro inline e impede o envio.
