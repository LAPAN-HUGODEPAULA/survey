## ADDED Requirements

### Requirement: Reporte de Estágio via API
Os serviços de IA DEVEM expor o estágio atual do processamento de longa duração para o cliente frontend.

#### Scenario: Consultar estágio via polling
- **WHEN** o frontend envia uma requisição de análise
- **THEN** o backend retorna um ID de tarefa e expõe um endpoint `/status/{task_id}`
- **AND** a resposta de status inclui o campo `stage` (ex: `analyzing`, `drafting`) e `percent` opcional

### Requirement: Contrato de Erro Estruturado para IA
As falhas de processamento de IA DEVEM retornar um objeto de erro que classifique a recuperabilidade do problema.

#### Scenario: Erro transiente de IA
- **WHEN** o serviço de IA falha devido a timeout ou sobrecarga
- **THEN** a API retorna um código de erro 503 com o campo `retryable: true`
- **AND** fornece um `userMessage` em pt-BR focado em tentar novamente em instantes
