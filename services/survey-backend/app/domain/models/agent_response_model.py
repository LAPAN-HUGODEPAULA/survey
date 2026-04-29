from pydantic import BaseModel, ConfigDict, Field


class AgentResponse(BaseModel):
    ok: bool | None = None
    input_type: str | None = None
    prompt_version: str | None = None
    questionnaire_prompt_version: str | None = None
    persona_skill_version: str | None = None
    model_version: str | None = None
    report: dict | None = None
    warnings: list[str] = Field(default_factory=list)
    classification: str | None = None
    medical_record: str | None = Field(default=None, alias="medicalRecord")
    error_message: str | None = Field(default=None, alias="errorMessage")
    ai_progress: dict | None = Field(default=None, alias="aiProgress")

    model_config = ConfigDict(populate_by_name=True)


class AgentArtifactResponse(AgentResponse):
    access_point_key: str | None = Field(default=None, alias="accessPointKey")
