## Context

Atualmente, o aplicativo `clinical-narrative` possui estados ricos (voz, transcrição, análise), mas a interface reflete esses estados de forma fragmentada. O rótulo "Fase da IA" é tecnicamente correto, mas não é amigável ao clínico. Além disso, os painéis de insights não seguem um padrão visual que comunique severidade ou tipo de informação.

## Goals / Non-Goals

**Goals:**
- Centralizar o status da IA em uma única barra de status do assistente.
- Humanizar os rótulos de fase do LangGraph para termos clínicos.
- Padronizar os cartões de insight com ícones e cores de severidade.
- Fornecer controles de cancelamento e retentativa em tempo real.

**Non-Goals:**
- Alterar o motor de IA ou o fluxo do LangGraph no backend.
- Implementar novos tipos de análise clínica (foco exclusivo em UI/UX).

## Decisions

### 1. Novo Componente: `DsAssistantStatusBar`
- **Rationale**: Unificar a comunicação de estado reduz a carga cognitiva do clínico.
- **Implementation**: Um widget persistente acima da área de entrada que exibe:
  - Ícone de atividade (ex: pulsando durante análise).
  - Texto humanizado da fase (ex: "Organizando a anamnese").
  - Botões de ação contextuais (Cancelar/Tentar).

### 2. Tradução de Fases (Mapeamento)
- **Rationale**: Termos como `intake` ou `assessment` são jargões de desenvolvimento de agentes.
- **Mapping**:
  - `intake` -> "Organizando a anamnese"
  - `assessment` -> "Analisando sinais clínicos"
  - `plan` -> "Estruturando o plano"
  - `wrap_up` -> "Preparando o encerramento"

### 3. Novo Componente: `DsInsightCard`
- **Rationale**: Insights precisam ser escaneáveis e categorizados por importância.
- **Implementation**: Widget que utiliza o `DsFeedbackModel` para definir:
  - `severity=info`: Sugestões e hipóteses (Ícone: `lightbulb_outline`).
  - `severity=warning`: Alertas e inconsistências (Ícone: `warning_amber_rounded`).
  - `severity=success`: Documentos e conclusões confirmadas (Ícone: `check_circle_outline`).

###  decision 4: Gerenciador de Estado Unificado
- **Rationale**: Facilitar a sincronização entre voz, chat e análise.
- **Implementation**: Introduzir um `ClinicalAssistantController` que escuta múltiplos streams e expõe um único estado consolidado para a UI.

## Risks / Trade-offs

- **[Risco]** A barra de status pode ocupar espaço precioso em telas pequenas. → **Mitigação**: O componente será colapsável ou terá uma versão compacta para mobile.
- **[Trade-off]** Humanizar os rótulos pode ocultar detalhes técnicos úteis para depuração. → **Mitigação**: Manter os logs técnicos originais acessíveis via ferramentas de desenvolvedor ou modo de suporte.
