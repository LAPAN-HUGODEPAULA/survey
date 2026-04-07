## 1. Design System: Componentes de Assistente

- [ ] 1.1 Implementar o widget `DsAssistantStatusBar` com suporte a ícones de atividade e botões de ação.
- [ ] 1.2 Implementar o widget `DsInsightCard` utilizando a taxonomia de severidade do `DsFeedbackModel`.
- [ ] 1.3 Criar o mapeamento de tradução de fases técnicas para pt-BR clínico ("Organizando a anamnese", etc.).

## 2. Implementação no Clinical Narrative

- [ ] 2.1 Criar o `ClinicalAssistantController` para consolidar os streams de estado de voz, transcrição e análise.
- [ ] 2.2 Integrar a `DsAssistantStatusBar` na tela de chat clínico, acima do campo de entrada.
- [ ] 2.3 Refatorar o painel de insights da sessão para utilizar o novo componente `DsInsightCard`.
- [ ] 2.4 Implementar a lógica de controle (Cancelar/Tentar Novamente) na barra de status.

## 3. Verificação

- [ ] 3.1 Verificar se as fases técnicas do LangGraph são exibidas com os nomes humanizados em pt-BR.
- [ ] 3.2 Validar se o botão de "Cancelar" interrompe corretamente o processamento visual e lógico.
- [ ] 3.3 Garantir que os insights exibem o ícone e a cor de severidade corretos conforme o tipo.
- [ ] 3.4 Verificar se todos os textos e rótulos utilizam acentuação correta em Português Brasileiro.
