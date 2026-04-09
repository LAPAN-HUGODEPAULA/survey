from datetime import datetime, timezone

from bson import ObjectId

from app.persistence.repositories.survey_response_repo import SurveyResponseRepository


class _FakeDatabase(dict):
    def __getitem__(self, item):  # noqa: D401 - test helper
        return super().setdefault(item, {})


def test_normalize_strips_internal_worker_fields() -> None:
    repo = SurveyResponseRepository(_FakeDatabase())
    response_id = ObjectId()
    payload = {
        "_id": response_id,
        "surveyId": "survey-1",
        "creatorId": "creator-1",
        "testDate": datetime.now(timezone.utc),
        "screenerId": "screener-1",
        "answers": [{"id": 1, "answer": "A"}],
        "agentResponse": {"errorMessage": "boom"},
        "agentResponseStatus": "failed",
        "agentResponseUpdatedAt": datetime.now(timezone.utc),
    }

    normalized = repo._normalize(payload)

    assert normalized["_id"] == str(response_id)
    assert "agentResponse" not in normalized
    assert "agentResponseStatus" not in normalized
    assert "agentResponseUpdatedAt" not in normalized
