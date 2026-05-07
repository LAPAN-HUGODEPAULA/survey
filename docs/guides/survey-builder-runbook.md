# Guia de Operação: Plataforma LAPAN Survey Builder

Este documento fornece instruções abrangentes sobre como operar o **Survey Builder**, a ferramenta administrativa central para governança de questionários e inteligência artificial da Plataforma LAPAN.

## 1. Visão Geral

O **Survey Builder** é projetado para administradores e gestores clínicos. Ele permite o controle total sobre:
- **Questionários**: Definição de perguntas e lógica clínica padrão.
- **Catálogo de Prompts**: Instruções reutilizáveis para a IA.
- **Habilidades de Persona**: Tom de voz e formato de saída dos laudos.
- **Pontos de Acesso (Agent Access Points)**: Configuração de como as aplicações (Screener, Patient, Narrative) se conectam ao motor de IA.

---

## 2. Pontos de Acesso (Agent Access Points)

Os Pontos de Acesso são o "cérebro" da integração. Eles mapeiam uma ação do usuário (ex: "clicar em gerar laudo") para uma configuração específica de IA.

### 2.1 Campos Principais
- **Chave do Ponto de Acesso (Access Point Key)**: Identificador único usado pelo código-fonte (ex: `survey_frontend.clinical_report.generator`).
- **App de Origem & Fluxo**: Metadados para organizar onde este ponto é usado.
- **ID do Questionário (Survey ID)**: Associa este ponto a um questionário específico (ex: `chyps_br_v1`).

### 2.2 Hierarquia de Herança (O conceito mais importante)
Você não precisa configurar tudo em todo lugar. O sistema segue esta ordem de prioridade:
1. **Overrides explícitos da requisição** (uso técnico em chamadas diretas/API).
2. **Configuração Manual no Ponto de Acesso**: se você selecionar Prompt/Persona/`aiConfig` específico, ele será usado.
3. **Herança do Questionário**: para Prompt/Persona, quando marcado **"Herdar do questionário"** (disponível com Survey associado).
4. **Configuração Global de IA**: para `aiConfig`, quando o ponto de acesso está em **"Use Global AI Settings"**.
5. **Fallback de ambiente**: somente último recurso operacional.

**Exemplo Prático:**
Se você quer que o Ponto de Acesso use sempre o que foi definido no questionário, selecione o questionário em **"Survey associado"** e mude os campos de Prompt e Persona para **"Herdar do questionário"**.

### 2.3 Uso Global vs. Específico
- **Survey Associado**: 
    - Selecione um questionário para ativar a herança e vincular a IA a um contexto clínico específico.
    - Selecione **"Global"** para fluxos que não dependem de um questionário (como análise de conversas livres). Neste modo, a herança é desativada e você deve selecionar um Prompt e Persona explicitamente.

---

## 3. Configuração de IA (Centralizada)

Agora é possível controlar o comportamento do modelo sem tocar no código ou em arquivos `.env`.

### 3.1 Provedor e Modelos
Na seção **Configuração de IA** de um Ponto de Acesso, você pode definir:
- **Provedor Primário**: `glm` (Zhipu AI) ou `gemini` (Google).
- **Modelo Primário**: Ex: `glm-4.5-flash` ou `gemini-1.5-pro`.
- **Temperatura**: 
    - `0.0`: Máxima precisão e consistência (ideal para análise clínica).
    - `0.7+`: Mais "criatividade" (não recomendado para laudos).

### 3.3 Esquema Canônico de IA (`aiConfig`)
Toda configuração de IA no Builder usa apenas o esquema `aiConfig`:
- `primaryProvider`
- `primaryModel`
- `fallbackProvider`
- `fallbackModel`
- `temperature`
- `reasoningEffort`
- `enableCaching`

Campos legados (`aiProvider`, `glmModel`, `geminiModel`) foram aposentados e não devem ser usados.

### 3.2 Overrides do Orchestrator
Para casos especiais, você pode sobrescrever as instruções mestras do sistema:
- **System Prompt Override**: Altera a lógica fundamental de como a IA interpreta os dados.
- **Format Prompt Override**: Altera a estrutura do JSON/Markdown de saída.

---

## 4. Gerenciamento de Prompts e Personas

### 4.1 Catálogo de Prompts
Localizado em **"Prompts Reutilizáveis"**. Contém a lógica de interpretação clínica.
- **Dica**: Use versões (ex: `v1`, `v2`) nas chaves para testar novas lógicas sem quebrar as antigas.

### 4.2 Habilidades de Persona
Define "quem" está escrevendo o laudo.
- **Exemplos**:
    - `parental_guidance`: Linguagem acolhedora para pais.
    - `clinical_diagnostic_report`: Linguagem técnica para outros médicos.

---

## 5. Exemplos de Configuração

### Caso A: Novo teste de modelo para Triagem
Você quer testar se o `gemini-1.5-pro` é melhor que o `glm` apenas na triagem pública:
1. Vá em **Pontos de Acesso**.
2. Edite `survey_patient.thank_you.auto_analysis`.
3. Em **Configuração de IA**, mude o Provedor para `gemini` e selecione o modelo Pro.
4. Salve. O efeito é imediato para todos os pacientes.

### Caso B: Laudo em formato específico para Escola
Você precisa que o laudo de um questionário específico tenha uma seção de "Dicas Pedagógicas":
1. Crie um novo **Persona Skill** chamado `school_report_v2`.
2. Vá no **Questionário** desejado.
3. No campo **Persona Padrão**, selecione `school_report_v2`.
4. Garanta que o Ponto de Acesso correspondente esteja com o campo de Persona **vazio** para herdar esta nova definição.

---

## 6. Resolução de Problemas (Troubleshooting)

### Erro 409 ao Deletar Prompt
O sistema impede a deleção de prompts que ainda estão associados a Questionários ou Pontos de Acesso para evitar "quebra" do motor de IA. 
- **Solução**: Reatribua os itens dependentes para outro prompt antes de excluir.

### Alterações não aparecem
O backend utiliza um cache de curta duração (60 segundos) para os prompts por motivos de performance. Se você alterou um texto e não viu o efeito imediato, aguarde 1 minuto.

---

## 7. Glossário Técnico e Roteamento

Para configurar corretamente um Ponto de Acesso, é fundamental entender como o sistema mapeia a aplicação para a IA. Usaremos como exemplo o ponto **"Análise da triagem do paciente"** (`survey_patient.thank_you.auto_analysis`).

### 7.1 Superfície de Origem
Identifica **QUAL aplicação** está fazendo a chamada. 
- *Exemplo:* `survey-patient` (App público de triagem).

### 7.2 Fluxo de Runtime
Identifica o **MOMENTO exato** dentro da aplicação em que a IA é acionada. 
- *Exemplo:* `thank_you.auto_analysis` (Disparado na tela de agradecimento após o envio das respostas).

### 7.3 Chave Estável (Access Point Key)
O **Identificador Único** que une o código-fonte ao banco de dados. É o nome da "tomada" onde a IA está conectada.
- *Exemplo:* `survey_patient.thank_you.auto_analysis`. 
- **Atenção**: Se esta chave for alterada no Builder sem uma mudança correspondente no código, a conexão entre o App e a IA será quebrada.

### 7.4 Ponto de Injeção Suportado
Um **Atalho ou Template** que preenche automaticamente os campos acima. O Builder possui um catálogo de pontos conhecidos para evitar erros de digitação. Ao selecionar um ponto do catálogo, a Chave Estável e a Superfície são configuradas instantaneamente.

### 7.5 Pontos observados no runtime
Recurso de **Autodescoberta**. Mostra chaves de IA que as aplicações tentaram usar, mas que ainda não possuem uma configuração criada no Builder. Útil para identificar novas funcionalidades adicionadas por desenvolvedores que ainda precisam de governança de prompt.

---
*Documentação atualizada em: Maio de 2026*
