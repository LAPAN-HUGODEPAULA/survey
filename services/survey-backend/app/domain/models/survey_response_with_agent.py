from pydantic import ConfigDict, Field
from typing import Optional

from app.domain.models.agent_response_model import AgentResponse
from app.domain.models.survey_response_model import SurveyResponse


class SurveyResponseWithAgent(SurveyResponse):
    agent_response: Optional[AgentResponse] = Field(default=None, alias="agentResponse")

    model_config = ConfigDict(populate_by_name=True)
