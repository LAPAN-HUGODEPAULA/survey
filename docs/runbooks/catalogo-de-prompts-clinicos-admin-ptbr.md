# Runbook do Administrador do Catalogo de Prompts Clinicos

## Objetivo

Este runbook orienta o administrador autorizado do `survey-builder` a registrar, revisar, atualizar e validar entradas do catalogo de prompts clinicos com seguranca.

Escopo:

- `QuestionnairePrompts`
- `PersonaSkills`
- `Output Profiles`
- configuracoes de `Agent Access Points`

Este documento descreve o fluxo operacional.
As regras de arquitetura e autoria estao em [clinical-prompt-catalog-governance.md](/home/hugo/Documents/LAPAN/dev/survey/docs/clinical-prompt-catalog-governance.md).

## Regra Principal

Cada registro deve ter uma responsabilidade unica.

- logica clinica do instrumento: `QuestionnairePrompts`
- tom, audiencia e limites de linguagem: `PersonaSkills`
- estrutura de saida: `Output Profiles`
- escolha do conjunto final em um fluxo de execucao: `Agent Access Points`

Se uma instrucao mistura duas responsabilidades, ela deve ser separada antes de salvar.

## Pre-requisitos

Antes de editar o catalogo:

1. entrar no `survey-builder` com conta de administrador autorizada
2. confirmar qual questionario, audiencia e superficie de uso serao alterados
3. abrir a documentacao de governanca e o bootstrap pack mais recente
4. preparar apenas exemplos sinteticos, nunca dados reais de pacientes

## Fluxo Seguro de Cadastro ou Revisao

1. Identifique o objetivo da alteracao.
2. Classifique a alteracao na camada correta.
3. Edite primeiro em rascunho.
4. Revise o conteudo com checklist tecnico e de privacidade.
5. Valide coerencia com `outputProfile` e `accessPoint` planejados.
6. Somente depois solicite ou execute a publicacao da nova versao ativa.

## Como decidir a camada correta

### Vai para `QuestionnairePrompts`

- regra de pontuacao
- mapeamento item-eixo
- limiar de interpretacao
- regra para dados ausentes
- restricoes de inferencia clinica do instrumento

### Vai para `PersonaSkills`

- tom tecnico ou acessivel
- audiencia alvo
- nivel de vocabulario
- forma de declarar incerteza
- o que enfatizar ou evitar na narrativa

### Vai para `Output Profiles`

- estrutura da resposta
- campos ou secoes obrigatorias
- restricoes de formato
- compatibilidade com JSON ou exportacao

### Vai para `Agent Access Points`

- qual fluxo usa qual conjunto de prompt
- padrao por tela, jornada ou acao
- nome estavel do ponto de entrada

## Checklist de Revisao

Antes de salvar:

- o registro possui uma unica responsabilidade
- a chave esta estavel e segue o padrao de nomes
- nao ha duplicacao de logica entre questionario e persona
- nao ha instrucao de roteamento dentro do prompt
- o texto nao contem PHI, segredos, tokens ou dados reais
- a linguagem deixa claro quando o instrumento e apenas um screener
- o conteudo esta consistente com o `outputProfile` esperado

## Checklist de Validacao Antes de Publicar

- o rascunho passou por revisao clinica quando necessario
- os exemplos sao sinteticos
- a versao ativa anterior continua disponivel para rollback por nova publicacao
- o `accessPoint` planejado referencia chaves existentes
- as restricoes de formato continuam compativeis com o runtime

## Exemplos Estruturados

### Exemplo 1: ajuste de regra de pontuacao

Solicitacao:
- "o NeuroCheck deve marcar sobrecarga biologica acima de 24"

Destino correto:
- `QuestionnairePrompts`

Motivo:
- e regra de interpretacao do instrumento

Nao colocar em:
- `PersonaSkills`
- `Output Profiles`

### Exemplo 2: laudo precisa ficar mais compreensivel para familia

Destino correto:
- `PersonaSkills`

Motivo:
- e ajuste de audiencia, tom e vocabulario

Nao colocar em:
- `QuestionnairePrompts`

### Exemplo 3: exportacao escolar precisa seguir secoes fixas

Destino correto:
- `Output Profiles`

Motivo:
- e restricao estrutural da saida

### Exemplo 4: relatorio automatico apos envio no app do paciente

Destino correto:
- `Agent Access Points`

Motivo:
- e decisao de qual stack deve ser usada em um fluxo especifico

## Boas Praticas de Escrita

- usar portugues brasileiro quando o destino final for pt-BR
- escrever instrucoes curtas, deterministicas e revisaveis
- separar regras em listas claras
- declarar explicitamente o que o modelo nao deve fazer
- preferir tabelas ou bullets para mapeamentos

## Privacidade e Conteudo Proibido

Nunca incluir:

- nome real de paciente
- data de nascimento real
- CPF, RG, telefone, email ou endereco
- numero de prontuario
- imagens, trechos de consulta, ou identificadores vindos de casos reais
- segredos, chaves de API, tokens, cookies ou URLs internas sensiveis

Alternativas seguras:

- `PACIENTE_A`
- `ID_EXEMPLO_001`
- datas ficticias
- resultados sinteticos e anonimizados

## Fluxo de Publicacao

### Salvar

- grava o rascunho
- nao muda a versao ativa
- permite iteracao interna

### Publicar

- cria nova versao ativa
- incrementa a versao
- preserva historico imutavel

Regra:
- nunca sobrescrever historico ativo manualmente
- para voltar atras, publique uma nova versao baseada em conteudo anteriormente aprovado

## Validacao Pos-Edicao

Depois da alteracao:

1. confirmar que a chave salva esta correta
2. revisar se o registro aparece na camada esperada
3. validar um exemplo sintetico representativo
4. confirmar que a saida continua compativel com o destino de uso
5. registrar observacoes para futura publicacao, se ainda estiver em rascunho

## Quando interromper a operacao

Pare e revise antes de seguir se:

- a alteracao mistura regra clinica com tom narrativo
- o texto exige dados reais para parecer valido
- a chave pretendida conflita com outra entrada
- o `accessPoint` precisa referenciar registro que ainda nao existe
- a equipe nao decidiu se a mudanca e apenas rascunho ou nova versao ativa
