"""In-memory progress tracking for LangGraph execution stages."""

from __future__ import annotations

from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from threading import Lock
from typing import Any


_STAGE_MESSAGES: dict[str, str] = {
    "loading_context": "Estamos reunindo as respostas do questionário e as instruções clínicas para o caso.",
    "analyzing": "Estamos analisando os sinais principais do caso para uma leitura inicial mais cuidadosa.",
    "drafting": "Estamos escrevendo a primeira versão do documento com o tom adequado ao público-alvo.",
    "reviewing": "Estamos revisando o conteúdo para garantir que as informações sejam claras e confiáveis.",
    "completed": "A geração foi concluída com sucesso.",
}

_AGENT_STAGE_MAP: dict[str, tuple[str, int]] = {
    "ContextLoader": ("loading_context", 15),
    "ClinicalAnalyzer": ("analyzing", 45),
    "PersonaWriter": ("drafting", 75),
    "ReflectorNode": ("reviewing", 90),
}


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


@dataclass
class AIProgressSnapshot:
    """Serializable progress snapshot for a single request execution."""

    request_id: str
    stage: str
    stage_label: str
    percent: int
    status: str
    severity: str
    retryable: bool
    user_message: str
    updated_at: str

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


class ProgressTracker:
    """Thread-safe in-memory store keyed by request id."""

    def __init__(self) -> None:
        self._data: dict[str, AIProgressSnapshot] = {}
        self._lock = Lock()

    def start(self, request_id: str) -> None:
        with self._lock:
            self._data[request_id] = AIProgressSnapshot(
                request_id=request_id,
                stage="queued",
                stage_label="Na fila",
                percent=5,
                status="processing",
                severity="info",
                retryable=False,
                user_message="Seu pedido foi recebido e está na fila.",
                updated_at=_now_iso(),
            )

    def update_stage(self, request_id: str, agent_type: str) -> None:
        mapped = _AGENT_STAGE_MAP.get(agent_type)
        if mapped is None:
            return
        stage, percent = mapped
        with self._lock:
            current = self._data.get(request_id)
            if current is None:
                return
            current.stage = stage
            current.stage_label = _human_stage_label(stage)
            current.percent = percent
            current.status = "processing"
            current.severity = "info"
            current.retryable = False
            current.user_message = _STAGE_MESSAGES.get(stage, current.user_message)
            current.updated_at = _now_iso()

    def complete(self, request_id: str) -> None:
        with self._lock:
            current = self._data.get(request_id)
            if current is None:
                return
            current.stage = "completed"
            current.stage_label = "Concluído"
            current.percent = 100
            current.status = "success"
            current.severity = "success"
            current.retryable = False
            current.user_message = _STAGE_MESSAGES["completed"]
            current.updated_at = _now_iso()

    def fail(self, request_id: str, detail: str, *, retryable: bool) -> None:
        with self._lock:
            current = self._data.get(request_id)
            if current is None:
                return
            current.status = "failed"
            current.severity = "warning" if retryable else "critical"
            current.retryable = retryable
            current.user_message = detail
            current.updated_at = _now_iso()

    def get(self, request_id: str) -> dict[str, Any] | None:
        with self._lock:
            current = self._data.get(request_id)
            if current is None:
                return None
            return current.to_dict()


def _human_stage_label(stage: str) -> str:
    labels = {
        "queued": "Na fila",
        "loading_context": "Carregando contexto",
        "analyzing": "Analisando sinais",
        "drafting": "Escrevendo rascunho",
        "reviewing": "Revisando conteúdo",
        "completed": "Concluído",
    }
    return labels.get(stage, stage)

