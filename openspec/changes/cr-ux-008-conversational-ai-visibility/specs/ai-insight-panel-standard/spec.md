## ADDED Requirements

### Requirement: Painéis de Insights Tipados
Todo insight gerado por IA DEVE ser apresentado em um cartão (card) que identifique claramente sua severidade e tipo (sugestão, aviso, hipótese).

#### Scenario: Visualizar sugestão de IA
- **WHEN** a IA gera uma sugestão de conduta clínica
- **THEN** o sistema exibe um cartão com `severity=info`, ícone `lightbulb_outline` e título "Sugestão do Assistente"
- **AND** utiliza o idioma Português Brasileiro (pt-BR)

### Requirement: Severidade Visual de Insights
Os cartões de insight DEVEM utilizar cores e ícones consistentes com a taxonomia de feedback da plataforma (`info`, `success`, `warning`, `error`).

#### Scenario: Visualizar alerta clínico
- **WHEN** a IA detecta uma inconsistência ou risco clínico (ex: sinal de alerta)
- **THEN** o sistema exibe um cartão com `severity=warning`, ícone `warning_amber_rounded` e título "Alerta Clínico"
