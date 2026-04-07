## Why

Atualmente, o LAPAN Survey Platform é funcional e consistente, mas sua interface é percebida como "emocionalmente fria". Em contextos clínicos e de saúde mental, a redução do estresse, o aumento da confiança e a percepção de cuidado são fundamentais para o engajamento. Introduzir uma camada de design emocional ajudará a transformar a plataforma de uma ferramenta técnica em uma experiência empática, respeitosa e encorajadora tanto para pacientes quanto para profissionais.

## What Changes

- Definição de perfis de tom de voz específicos por aplicativo (paciente: acolhedor; profissional: confiante; admin: eficiente).
- Implementação de micro-interações e animações de "deleite" em momentos de baixo risco (sucesso ao salvar, conclusão de setup).
- Personalização leve da interface para aumentar a conexão e a confiança (ex: uso de nomes, saudações contextuais).
- Redesenho de mensagens de conclusão para reconhecer o esforço do usuário, não apenas a submissão de dados.
- Aplicação de regras de "sycophancy" positiva (encorajamento) em fluxos de longa duração e esperas de IA.

## Capabilities

### New Capabilities
- `emotional-tone-standard`: Define as diretrizes de tom de voz, vocabulário e estilo para cada perfil de usuário e contexto de uso na plataforma.
- `user-personalization-ux`: Define padrões para o uso seguro e empático de dados do usuário (como nomes e histórico) para personalizar a experiência de interface.

### Modified Capabilities
- `ux-accessibility`: Expansão dos requisitos de acessibilidade cognitiva para incluir o suporte emocional e a redução de ansiedade via design.

## Impact

- `packages/design_system_flutter`: Novos componentes de feedback emocional e atualizações em ilustrações e animações.
- `apps/survey-patient`: Jornadas mais calmas, simples e reasseguradoras.
- `apps/survey-frontend`: Fluxos que comunicam competência e suporte ao profissional.
- `apps/survey-builder`: Experiência mais leve e de menor ruído para tarefas administrativas.
- `apps/clinical-narrative`: Interface que transmite confiança clínica e transparência.
