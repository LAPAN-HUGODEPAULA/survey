from typing import List, Optional

from pydantic import BaseModel, Field, ConfigDict


class AnalysisMessage(BaseModel):
    role: str
    content: str
    message_type: str = Field(..., alias="messageType")

    model_config = ConfigDict(extra="forbid", populate_by_name=True)


class Suggestion(BaseModel):
    id: str
    text: str
    category: str
    confidence: float = Field(ge=0, le=1)


class Entity(BaseModel):
    type: str
    value: str
    confidence: float = Field(ge=0, le=1)


class ClinicalAlert(BaseModel):
    id: str
    text: str
    severity: str
    evidence: Optional[str] = None


class DiagnosticHypothesis(BaseModel):
    id: str
    label: str
    confidence: float = Field(ge=0, le=1)
    evidence: Optional[str] = None


class KnowledgeItem(BaseModel):
    id: str
    label: str
    source: str
    reference: Optional[str] = None


class AnalysisRequest(BaseModel):
    session_id: Optional[str] = Field(default=None, alias="sessionId")
    phase: Optional[str] = None
    messages: List[AnalysisMessage]

    model_config = ConfigDict(extra="forbid", populate_by_name=True)


class AnalysisResponse(BaseModel):
    suggestions: List[Suggestion] = Field(default_factory=list)
    entities: List[Entity] = Field(default_factory=list)
    alerts: List[ClinicalAlert] = Field(default_factory=list)
    hypotheses: List[DiagnosticHypothesis] = Field(default_factory=list)
    knowledge: List[KnowledgeItem] = Field(default_factory=list)
    phase: Optional[str] = None
