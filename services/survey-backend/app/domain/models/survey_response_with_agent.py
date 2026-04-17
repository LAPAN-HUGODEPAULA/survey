from pydantic import ConfigDict, Field
from typing import Optional

from app.domain.models.agent_response_model import AgentArtifactResponse, AgentResponse
from app.domain.models.survey_response_model import SurveyResponse


class SurveyResponseWithAgent(SurveyResponse):
    agent_response: Optional[AgentResponse] = Field(default=None, alias="agentResponse")
    agent_responses: list[AgentArtifactResponse] = Field(
        default_factory=list,
        alias="agentResponses",
    )

    model_config = ConfigDict(populate_by_name=True)
