"""FastAPI routes for medication reference search."""

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, Field

from app.persistence.deps import get_reference_medication_repo
from app.persistence.repositories.reference_medication_repo import (
    ReferenceMedicationRepository,
)

router = APIRouter()


class MedicationSearchItem(BaseModel):
    """Public representation of a medication search result."""

    substance: str
    category: str
    trade_names: list[str] = Field(default_factory=list)


class MedicationSearchResponse(BaseModel):
    """Medication search response payload."""

    results: list[MedicationSearchItem] = Field(default_factory=list)


@router.get("/medications/search", response_model=MedicationSearchResponse)
async def search_medications(
    q: str = Query(..., description="Medication query text"),
    limit: int = Query(10, ge=1, le=50),
    repo: ReferenceMedicationRepository = Depends(get_reference_medication_repo),
):
    """Search medications by substance or trade name."""
    if len(q.strip()) < 3:
        return MedicationSearchResponse(results=[])

    matches = repo.search(q, limit=limit)
    return MedicationSearchResponse(
        results=[
            MedicationSearchItem(
                substance=item.substance,
                category=item.category,
                trade_names=item.trade_names,
            )
            for item in matches
        ]
    )
