## 1. Design System: Infraestrutura de Feedback

- [ ] 1.1 Criar a classe `DsFeedbackModel` com atributos de severidade, ícone, título e corpo.
- [ ] 1.2 Implementar o componente `DsMessageBanner` para avisos globais ou de seção.
- [ ] 1.3 Implementar o componente `DsInlineMessage` para mensagens contextuais em formulários.
- [ ] 1.4 Criar o wrapper `DsToast` sobre o `SnackBar` para notificações transientes padronizadas.
- [ ] 1.5 Implementar o componente `DsDialog` com suporte a verbos explícitos e estilos de severidade.

## 2. Refatoração e Implementação Piloto

- [ ] 2.1 Refatorar os cards de autenticação profissional em `packages/design_system_flutter` para usar `DsInlineMessage` em vez de banners binários.
- [ ] 2.2 Substituir usos de `SnackBar` puros por `DsToast` na tela de configurações do `survey-frontend`.
- [ ] 2.3 Implementar `DsDialog` de confirmação para exclusão de rascunhos em qualquer um dos aplicativos.

## 3. Verificação

- [ ] 3.1 Validar se as cores e ícones seguem rigorosamente o mapeamento de severidade (info, success, warning, error).
- [ ] 3.2 Verificar se todas as mensagens estão em Português Brasileiro perfeito com acentuação correta.
- [ ] 3.3 Garantir que os `Snackbars` agora são usados apenas para confirmações simples ou desfazer ações.
- [ ] 3.4 Verificar se os diálogos utilizam verbos explícitos (ex: "Excluir") em vez de apenas "OK".
