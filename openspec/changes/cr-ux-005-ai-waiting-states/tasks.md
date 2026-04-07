## 1. Backend: Contratos e Reporte de Estágios

- [ ] 1.1 Atualizar o `clinical-writer-api` para emitir eventos de estágio (LangGraph nodes).
- [ ] 1.2 Implementar endpoint de polling ou suporte a streaming no `survey-backend`.
- [ ] 1.3 Atualizar o contrato OpenAPI para incluir o objeto de progresso de IA.

## 2. Design System: Componentes e Microcopy

- [ ] 2.1 Implementar o componente `DsAIProgressIndicator` no `packages/design_system_flutter`.
- [ ] 2.2 Adicionar o mapeamento de microcopy em pt-BR (rótulos e reasseguramento) para cada estágio.
- [ ] 2.3 Garantir que o componente suporte um estado de erro com opção de `Retry`.

## 3. Implementação nos Aplicativos

- [ ] 3.1 Atualizar a página de agradecimento do `survey-patient` para usar o novo indicador de progresso durante a geração do resumo.
- [ ] 3.2 Atualizar o fluxo de laudo profissional no `survey-frontend`.
- [ ] 3.3 Implementar o novo estado de espera nos fluxos de transcrição e análise do `clinical-narrative`.

## 4. Verificação

- [ ] 4.1 Verificar se os estágios de IA transitam corretamente de "Recebido" até "Pronto".
- [ ] 4.2 Validar se a microcopy está em pt-BR perfeito com acentuação correta.
- [ ] 4.3 Garantir que o erro de timeout da IA apresente a opção de tentar novamente.
