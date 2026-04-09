## Why

Atualmente, o LAPAN Survey Platform possui indicadores de progresso fragmentados que não fornecem uma orientação consistente ao usuário em fluxos complexos (como preenchimento de questionários, cadastros e edição no builder). Estabelecer padrões de wayfinding ajuda o usuário a entender onde está, o que já completou e o que falta, reduzindo a ansiedade e melhorando a taxa de conclusão de tarefas.

## What Changes

- Padronização de indicadores de progresso para fluxos multi-etapas (mostrando etapas nomeadas, não apenas porcentagem).
- Integração com o modelo de feedback compartilhado (`cr-ux-001`) para comunicar transições de estado entre etapas (ex: sucessos, avisos de validação).
- Integração com os padrões de formulário estruturado (`cr-ux-003`) para refletir o estado de "rascunho salvo" ou "erros pendentes" diretamente nos indicadores de progresso (steppers/trilhas).
- Implementação de mecanismos de controle que permitam ao usuário voltar em etapas anteriores sem perda de dados (conforme `cr-ux-003`).
- Criação de componentes visuais que combinam texto descritivo com barras de progresso ou trilhas (steppers).
- Definição de estados de transição e orientação clara após redirecionamentos.

## Capabilities

### New Capabilities
- `multi-step-progress-standard`: Define como o progresso deve ser (MUST) visualizado em fluxos com mais de duas etapas, incluindo nomes de fases e estados de conclusão.
- `user-navigation-orientation`: Define padrões de feedback visual e textual para manter (MUST) o usuário orientado sobre sua posição na hierarquia do app e no fluxo atual.

### Modified Capabilities
- Nenhuma.

## Impact

- `packages/design_system_flutter`: Novos componentes de `DsStepper`, `DsProgressTracker` e atualizações no `DsSurveyProgressIndicator`.
- `apps/survey-patient`: Melhoria na jornada do paciente (Boas-vindas -> Questionário -> Relatório).
- `apps/survey-frontend`: Melhoria no fluxo de avaliação profissional.
- `apps/survey-builder`: Introdução de wayfinding em editores longos.
- `apps/clinical-narrative`: Melhoria na orientação durante a geração de documentos AI.
