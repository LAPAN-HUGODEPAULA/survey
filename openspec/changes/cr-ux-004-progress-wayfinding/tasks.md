## 1. Setup e Design System

- [ ] 1.1 Implementar o widget `DsStepper` com suporte a estados `todo`, `active` e `done`.
- [ ] 1.2 Implementar o widget `DsBreadcrumbs` para exibição de hierarquia de rotas.
- [ ] 1.3 Criar o widget `DsStickySectionHeader` para wayfinding em formulários longos.
- [ ] 1.4 Adicionar suporte a botões de "Voltar" contextuais no `DsPageHeader`.

## 2. Implementação em Fluxos Existentes

- [ ] 2.1 Atualizar a jornada do paciente em `survey-patient` para usar o `DsStepper` (Aviso -> Boas-vindas -> Instruções -> Questionário -> Relatório).
- [ ] 2.2 Atualizar o fluxo de avaliação profissional em `survey-frontend` com o novo stepper.
- [ ] 2.3 Implementar wayfinding no editor de questionários do `survey-builder` usando `DsStickySectionHeader`.
- [ ] 2.4 Adicionar feedback de transição ("Agora você pode visualizar...") em `clinical-narrative` e fluxos de relatório.

## 3. Verificação

- [ ] 3.1 Verificar se o progresso (texto e visual) é atualizado corretamente ao avançar em todos os apps.
- [ ] 3.2 Validar que o botão "Voltar" preserva os dados inseridos nas etapas anteriores.
- [ ] 3.3 Garantir que os nomes das etapas seguem o idioma pt-BR com acentuação correta.
- [ ] 3.4 Verificar se o stepper se comporta de forma responsiva em telas de diferentes larguras.
