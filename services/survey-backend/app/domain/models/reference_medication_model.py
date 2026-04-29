"""Domain model for reference medication records."""

from pydantic import BaseModel, ConfigDict


class ReferenceMedication(BaseModel):
    """Represents a normalized medication document used for lookup."""

    substance: str
    category: str
    trade_names: list[str]
    search_vector: list[str]

    model_config = ConfigDict(extra="forbid")
