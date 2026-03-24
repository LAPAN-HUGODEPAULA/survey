## ADDED Requirements
### Requirement: Sessao Conversacional
O sistema SHALL manter sessoes conversacionais com historico de mensagens e metadados basicos (data, autor, origem).

#### Scenario: Criar nova sessao
- **WHEN** o profissional iniciar uma nova consulta
- **THEN** o sistema cria uma sessao vazia e registra o contexto minimo

### Requirement: Persistencia de Historico
O sistema SHALL permitir recuperar o historico de uma sessao para continuidade do atendimento.

#### Scenario: Retomar sessao existente
- **WHEN** o profissional abrir uma sessao existente
- **THEN** o sistema retorna o historico de mensagens em ordem cronologica
