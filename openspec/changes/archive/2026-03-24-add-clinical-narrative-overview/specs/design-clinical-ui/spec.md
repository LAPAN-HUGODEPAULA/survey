## ADDED Requirements
### Requirement: Interface Conversacional
O sistema SHALL oferecer uma interface conversacional clara, com historico e entrada multimodal.

#### Scenario: Visualizar historico
- **WHEN** o profissional abrir uma sessao
- **THEN** o sistema mostra o historico em ordem e permite nova interacao

### Requirement: Consistencia de Design
O sistema SHALL seguir o design system compartilhado entre os apps.

#### Scenario: Aplicar tema compartilhado
- **WHEN** a tela principal do `clinical-narrative` for renderizada
- **THEN** o sistema aplica cores e componentes do `design_system_flutter`
