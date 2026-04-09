import asyncio
from typing import Any
from app.domain.models.ai_stages import AIProcessingStage, STAGE_MESSAGES_PTBR

class TaskManager:
    """Simple in-memory background task manager."""
    def __init__(self):
        self._tasks: dict[str, dict[str, Any]] = {}
        self._lock = asyncio.Lock()

    async def set_task(self, task_id: str, payload: dict[str, Any]) -> None:
        async with self._lock:
            current = self._tasks.get(task_id, {})
            current.update(payload)
            self._tasks[task_id] = current

    async def get_task(self, task_id: str) -> dict[str, Any] | None:
        async with self._lock:
            task = self._tasks.get(task_id)
            if task is None:
                return None
            return dict(task)

    async def update_stage(self, task_id: str, stage: AIProcessingStage, user_message: str | None = None) -> None:
        message = user_message or STAGE_MESSAGES_PTBR.get(stage, "")
        progress_update = {
            "ai_progress": {
                "stage": stage.value,
                "stageLabel": stage.name.replace("_", " ").title(), # Default label
                "userMessage": message,
                "status": "processing" if stage not in [AIProcessingStage.COMPLETED, AIProcessingStage.FAILED] else ("success" if stage == AIProcessingStage.COMPLETED else "failed")
            }
        }
        await self.set_task(task_id, progress_update)

task_manager = TaskManager()
