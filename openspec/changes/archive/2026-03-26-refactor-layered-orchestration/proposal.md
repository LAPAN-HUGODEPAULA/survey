# Change: Refactor Layered Graph Orchestration (Analyzer-Writer)

## Why

A arquitetura atual do `clinical-writer-api` utiliza nós monolíticos (`ConsultWriterNode`, `Survey7WriterNode`, `FullIntakeWriterNode`) que misturam a interpretação clínica dos dados com a geração da narrativa estilizada. Essa abordagem apresenta problemas significativos:

- **Acoplamento de Responsabilidades:** A lógica clínica (cálculo de scores, interpretação de limiares) está acoplada à regras de estilo (tom de voz, formatação).
- **Dificuldade de Manutenção:** A alteração de uma diretriz de estilo (ex: atualizar o tom de um relatório escolar) exige o toque em código ou em prompts que contêm lógica médica sensível, e vice-versa.
- **Limitação de Reuso:** A lógica clínica de um questionário não pode ser facilmente reutilizada em diferentes perfis de saída sem duplicação de prompts.
- **Risco de Alucinação:** Exigir que o modelo (LLM) processe a complexidade clínica e simultaneamente formate uma prosa longa e estilizada aumenta a carga cognitiva, elevando a chance de omissões ou saltos lógicos.

A refatoração introduzirá um fluxo de 4 estágios (`ContextLoader` -> `ClinicalAnalyzer` -> `PersonaWriter` -> `ReflectorNode`), reduzindo a responsabilidade de cada nó e melhorando a segurança e rastreabilidade da geração do relatório.

## What Changes

- Refatoração do `AgentState` (`TypedDict`) para suportar a passagem de fatos clínicos (JSON) entre os novos nós.
- Criação do `ContextLoader`: Nó responsável por buscar no MongoDB as coleções de `QuestionnairePrompts` (regras clínicas) e `PersonaSkills` (diretrizes de estilo), baseado na requisição.
- Criação do `ClinicalAnalyzer`: Nó que executa a interpretação clínica dos dados do questionário e gera estritamente um JSON de "Fatos Clínicos", sem prosa narrativa.
- Criação do `PersonaWriter`: Nó que consome os "Fatos Clínicos" estruturados e aplica o tom e as restrições da Persona, gerando o relatório final em Markdown.
- Atualização do `agent_graph.py` para instanciar a nova topologia linear, substituindo o roteamento monolítico de escrita atual.
- Configuração de compatibilidade retroativa para garantir que fluxos de trabalho legados ainda não migrados para o novo modelo de banco de dados continuem funcionando inalterados.

## Impact

- Affected specs:
  - `layered-graph-orchestration` (NEW)
  - `clinical-writer-prompt-resolution` (MODIFIED)
- Affected systems:
  - `services/clinical-writer-api` (Agent graph, State, Prompts)