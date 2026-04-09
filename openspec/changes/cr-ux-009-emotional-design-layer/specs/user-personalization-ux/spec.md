## ADDED Requirements

### Requirement: Saudações e Feedback Personalizados
O sistema DEVE utilizar dados básicos do usuário (ex: nome, nome clínico) para criar saudações e feedbacks mais empáticos e próximos, desde que não comprometa a privacidade.

#### Scenario: Saudação de Paciente
- **WHEN** o paciente informa seu nome na demografia
- **THEN** o sistema utiliza seu nome em mensagens de progresso e espera (ex: "Olá, [Nome]. Estamos preparando seu relatório")

#### Scenario: Saudação de Profissional
- **WHEN** o profissional acessa o painel
- **THEN** o sistema exibe uma saudação contextual e profissional (ex: "Bom dia, Dr(a). [Nome]. Você tem 3 atendimentos pendentes")

### Requirement: Personalização do Estado de Espera
As mensagens de espera DEVEM ser personalizadas para o contexto da tarefa atual para reduzir a ansiedade.

#### Scenario: Espera por IA de Narrativa
- **WHEN** a IA está gerando um documento clínico
- **THEN** o sistema exibe: "Olá, [Screener]. Estamos analisando os sinais principais do caso para gerar o rascunho. Isso levará apenas alguns instantes"
