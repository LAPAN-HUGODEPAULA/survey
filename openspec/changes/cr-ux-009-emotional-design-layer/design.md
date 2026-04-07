## Context

A plataforma LAPAN Survey é funcional, mas sua interface atual é percebida como técnica e fria. Em contextos de saúde e avaliação clínica, o design emocional desempenha um papel crucial na redução da ansiedade do paciente e no aumento da confiança do profissional. Este design introduz uma camada de suporte emocional através de tom de voz, personalização e micro-interações de deleite.

## Goals / Non-Goals

**Goals:**
- Centralizar o gerenciamento de tom de voz (Tone of Voice) no sistema de design.
- Implementar personalização segura (saudações e mensagens contextuais).
- Introduzir animações de "deleite" para reforço positivo em momentos de sucesso.
- Humanizar mensagens de espera e conclusão em todos os aplicativos.

**Non-Goals:**
- Implementar gamificação complexa ou sistemas de recompensa.
- Alterar as cores primárias ou a identidade visual base da plataforma.
- Modificar fluxos de autenticação ou segurança (apenas a interface/tom).

## Decisions

### 1. Tokenização de Tom de Voz (`DsToneTokens`)
- **Rationale**: Assim como cores e espaçamentos, o tom de voz deve ser um recurso de design governável e consistente.
- **Implementation**: Criar uma `ThemeExtension` chamada `DsToneTokens` que define estilos de escrita e exemplos de microcopy para cada perfil (`patient`, `professional`, `admin`).
- **Rationale for pt-BR**: Todas as strings de exemplo nos tokens serão em Português Brasileiro para garantir a naturalidade.

### 2. Provider de Tom Emocional (`DsEmotionalToneProvider`)
- **Rationale**: Aplicativos diferentes precisam de tons diferentes, mas compartilham componentes.
- **Implementation**: Um `InheritedWidget` que permite que componentes filhos (como `DsMessageBanner` ou `DsLoading`) adaptem sua linguagem automaticamente com base no perfil ativo no topo da árvore.

### 3. Sistema de "Momentos de Deleite" (`DsDelightSystem`)
- **Rationale**: Sucessos pequenos (como salvar um rascunho) são oportunidades para reduzir o estresse através de micro-animações.
- **Implementation**: Utilizar animações leves (CSS transitions ou Flutter animations nativas) integradas aos componentes de sucesso da `design_system_flutter`.

### 4. Personalização Contextual Segura
- **Rationale**: O uso do nome do usuário aumenta a percepção de cuidado e conexão.
- **Implementation**: Criar utilitários de formatação de strings que aceitem `UserContext` para injetar nomes e saudações de forma consistente, com fallbacks genéricos seguros para anonimato.

## Risks / Trade-offs

- **[Risk]** Tom excessivamente informal em contextos clínicos sérios. → **Mitigação**: O tom `professional` manterá um equilíbrio rigoroso entre empatia e autoridade clínica.
- **[Trade-off]** Aumento leve no tamanho do pacote devido a assets de animação. → **Mitigação**: Priorizar animações procedurais ou SVGs otimizados.
- **[Risk]** Personalização falhar em casos de dados incompletos. → **Mitigação**: Implementação rigorosa de fallbacks amigáveis (ex: "Olá! Tudo pronto por aqui").
