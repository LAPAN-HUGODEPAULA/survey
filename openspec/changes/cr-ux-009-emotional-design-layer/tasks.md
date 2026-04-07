## 1. Design System: Infraestrutura de Tom e Personalização

- [ ] 1.1 Criar a `ThemeExtension` `DsToneTokens` com suporte a perfis de tom (patient, professional, admin).
- [ ] 1.2 Implementar o `DsEmotionalToneProvider` para propagação de contexto de tom na árvore de widgets.
- [ ] 1.3 Implementar utilitários de personalização segura (`DsPersonalizationUtils`) com suporte a fallbacks.
- [ ] 1.4 Integrar `DsDelightSystem` para micro-animações de sucesso em componentes base (Snackbars, Banners).

## 2. Implementação nos Aplicativos

- [ ] 2.1 Aplicar o tom `patient` no `survey-patient` e atualizar mensagens de boas-vindas e conclusão.
- [ ] 2.2 Aplicar o tom `professional` no `survey-frontend` e `clinical-narrative`.
- [ ] 2.3 Aplicar o tom `admin` no `survey-builder`.
- [ ] 2.4 Integrar saudações personalizadas nas telas principais e estados de espera de IA (narrativa clínica).

## 3. Verificação e Refinamento

- [ ] 3.1 Validar se a alternância de temas preserva a consistência do tom emocional.
- [ ] 3.2 Verificar se as saudações personalizadas tratam corretamente dados ausentes (fallbacks).
- [ ] 3.3 Testar as micro-animações de deleite em diferentes dispositivos para performance.
- [ ] 3.4 Revisar todos os textos e rótulos para garantir acentuação correta e naturalidade em Português Brasileiro.
