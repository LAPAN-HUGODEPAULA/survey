from enum import Enum

class AIProcessingStage(str, Enum):
    QUEUED = "queued"
    LOADING_CONTEXT = "loading_context"
    ANALYZING = "analyzing"
    DRAFTING = "drafting"
    REVIEWING = "reviewing"
    FORMATTING = "formatting"
    COMPLETED = "completed"
    FAILED = "failed"

STAGE_MESSAGES_PTBR = {
    AIProcessingStage.QUEUED: "Na fila de processamento.",
    AIProcessingStage.LOADING_CONTEXT: "Carregando contexto e instruções.",
    AIProcessingStage.ANALYZING: "Analisando as informações principais.",
    AIProcessingStage.DRAFTING: "Escrevendo a primeira versão.",
    AIProcessingStage.REVIEWING: "Revisando consistência e segurança.",
    AIProcessingStage.FORMATTING: "Preparando a apresentação final.",
    AIProcessingStage.COMPLETED: "Processamento concluído.",
    AIProcessingStage.FAILED: "Falha no processamento.",
}
