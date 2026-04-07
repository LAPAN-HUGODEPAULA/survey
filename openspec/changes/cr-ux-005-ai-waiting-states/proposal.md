## Why

Atualmente, as operações de IA de longa duração (geração de laudos, análise de narrativa clínica, transcrição) utilizam estados de espera genéricos como "Processando..." ou "Gerando relatório...". Isso cria ansiedade, incerteza sobre o progresso e risco de abandono pelo usuário, que não sabe se o sistema está travado ou em qual estágio a tarefa se encontra. Redesenhar esses estados para exibir progressos baseados em estágios humanos e mensagens de reasseguramento é essencial para construir confiança e melhorar a percepção de qualidade da plataforma.

## What Changes

- Redesenho dos estados de espera de IA em todos os aplicativos para exibir progresso baseado em estágios (ex: "Validando dados", "Analisando sinais", "Escrevendo rascunho").
- Implementação de microcopy em Português Brasileiro (pt-BR) focado em tranquilizar o usuário e explicar o valor da espera.
- Introdução de suporte a progresso assíncrono ou estágios observáveis nos contratos de API para tarefas de longa duração.
- Padronização de mensagens de falha de IA para distinguir problemas recuperáveis (tentar novamente) de resultados parciais ou falhas críticas.
- Permissão para que o usuário continue revisando ou lendo conteúdos anteriores enquanto a IA trabalha em segundo plano, quando aplicável.

## Capabilities

### New Capabilities
- `ai-wait-experience`: Define o padrão de interação visual e textual para esperas de IA, incluindo o modelo de estágios, microcopy de reasseguramento e tratamento de erros.
- `ai-progress-api-contract`: Define os requisitos técnicos para que os serviços de backend (survey-backend, clinical-writer-api) reportem o estágio atual de uma tarefa de longa duração para o frontend.

### Modified Capabilities
- `error-handling`: Atualização para incluir a distinção de severidade e recuperabilidade específica para falhas de processamento de IA.

## Impact

- `packages/design_system_flutter`: Novos componentes ou atualizações em `DsLoading` e `DsStatusIndicator` para suportar rótulos de estágio e progresso rico.
- `apps/survey-patient` & `apps/survey-frontend`: Melhoria na espera de geração de relatório após o questionário.
- `apps/clinical-narrative`: Melhoria nos fluxos de análise de chat, transcrição e geração de documentos.
- `services/clinical-writer-api`: Implementação de mecanismos de reporte de estágio durante o grafo de execução (LangGraph).
- `services/survey-backend`: Adaptação do cliente de integração para propagar estados de estágio para o frontend.
