## 1. Setup e Design System

- [ ] 1.1 Adicionar `connectivity_plus` às dependências do `packages/design_system_flutter`.
- [ ] 1.2 Implementar o widget `DsEmptyState` com suporte a ícone, título, descrição e ação primária.
- [ ] 1.3 Implementar o utilitário `DsErrorMapper` para traduzir exceções técnicas em mensagens amigáveis em pt-BR.
- [ ] 1.4 Atualizar o componente `DsError` para suportar o callback opcional `onRetry` e exibir o botão "Tentar Novamente".
- [ ] 1.5 Implementar o `DsOfflineBanner` e integrá-lo ao `DsScaffold` para exibição automática via stream de conectividade.

## 2. Implementação Piloto

- [ ] 2.1 Atualizar o catálogo de questionários no `survey-frontend` para usar `DsEmptyState` e mensagens amigáveis de erro via `DsErrorMapper`.
- [ ] 2.2 Atualizar a lista de screeners (profissionais) para usar o novo padrão de estado vazio.
- [ ] 2.3 Implementar o botão de "Tentar Novamente" no carregamento inicial de surveys em caso de falha de rede.

## 3. Verificação

- [ ] 3.1 Verificar se o estado vazio exibe a explicação em pt-BR e o botão de ação sugerida.
- [ ] 3.2 Validar se o banner offline aparece automaticamente ao desconectar a rede.
- [ ] 3.3 Garantir que erros técnicos (ex: 500 ou Timeout) sejam exibidos como mensagens amigáveis com opção de "Tentar Novamente".
- [ ] 3.4 Verificar se todos os novos textos em pt-BR utilizam acentuação correta.
