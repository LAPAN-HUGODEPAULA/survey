import os
import pytest
from pymongo import MongoClient
from app.persistence.repositories.screener_repo import ScreenerRepository, SYSTEM_SCREENER_EMAIL, SYSTEM_SCREENER_ID

# This test would require a running MongoDB instance, usually provided in CI or via docker-compose
@pytest.mark.skipif(os.environ.get("MONGO_URL") is None, reason="MONGO_URL not set for integration tests")
def test_ensure_system_screener_real_mongo():
    mongo_url = os.environ.get("MONGO_URL")
    client = MongoClient(mongo_url)
    db = client["test_survey_db"]
    
    # Ensure clean state
    db["screeners"].delete_many({})
    
    repo = ScreenerRepository(db)
    
    # Test creation
    screener = repo.ensure_system_screener("secure-hash")
    assert screener.email == SYSTEM_SCREENER_EMAIL
    assert screener.isBuilderAdmin is True
    
    # Test promotion of existing
    db["screeners"].update_one(
        {"_id": SYSTEM_SCREENER_ID},
        {"$set": {"isBuilderAdmin": False}}
    )
    
    screener_updated = repo.ensure_system_screener("secure-hash")
    assert screener_updated.isBuilderAdmin is True
    
    # Cleanup
    client.drop_database("test_survey_db")
    client.close()
