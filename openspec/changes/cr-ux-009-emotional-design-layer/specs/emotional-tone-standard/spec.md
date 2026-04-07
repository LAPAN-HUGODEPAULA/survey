## ADDED Requirements

### Requirement: Perfis de Tom de Voz por Aplicativo
O sistema DEVE aplicar perfis de tom de voz diferenciados de acordo com o contexto e o usuário final para reduzir o estresse e aumentar a confiança.

#### Scenario: Tom para Pacientes (survey-patient)
- **WHEN** o usuário está realizando uma triagem pública
- **THEN** o sistema utiliza um tom calmo, acolhedor e simples (ex: "Estamos aqui para ajudar a entender melhor sua visão")
- **AND** evita termos técnicos ou clínicos excessivos

#### Scenario: Tom para Profissionais (survey-frontend / clinical-narrative)
- **WHEN** o profissional está realizando um atendimento
- **THEN** o sistema utiliza um tom claro, profissional e de suporte (ex: "Tudo pronto para iniciar a narrativa clínica")
- **AND** foca em competência e eficiência

#### Scenario: Tom para Administradores (survey-builder)
- **WHEN** o administrador está editando um questionário
- **THEN** o sistema utiliza um tom preciso, leve e de baixo ruído (ex: "Alterações salvas. O questionário está pronto para uso")

### Requirement: Reconhecimento de Esforço em Mensagens de Conclusão
As mensagens de conclusão de fluxos DEVEM reconhecer o esforço do usuário e o propósito da tarefa, em vez de apenas confirmar a recepção de dados.

#### Scenario: Conclusão do Paciente
- **WHEN** o paciente finaliza o questionário
- **THEN** o sistema exibe: "Obrigado por sua colaboração. Suas respostas ajudam a construir um olhar mais cuidadoso para sua saúde"

#### Scenario: Conclusão do Profissional
- **WHEN** o profissional finaliza uma sessão
- **THEN** o sistema exibe: "Sessão concluída com sucesso. O registro clínico foi gerado e está pronto para sua revisão"
