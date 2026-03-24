## ADDED Requirements
### Requirement: Sugestoes Clinicas
O sistema SHALL sugerir perguntas de follow-up com base no contexto da conversa.

#### Scenario: Identificar informacao ausente
- **WHEN** o contexto indicar lacunas em dados essenciais
- **THEN** o sistema sugere perguntas para completar o registro

### Requirement: Assistencia de Codigos Clinicos
O sistema SHALL sugerir codigos CID-10 relevantes quando apropriado.

#### Scenario: Sugerir CID-10
- **WHEN** sinais e sintomas forem identificados no texto
- **THEN** o sistema sugere codigos CID-10 candidatos
