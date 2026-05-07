import os
from unittest.mock import MagicMock
from app.main import _ensure_global_ai_defaults


def test_ensure_global_ai_defaults_seeds_when_missing():
    repo = MagicMock()
    repo.get_json.return_value = None
    
    # Mock environment variables
    os.environ["GEMINI_MODEL"] = "test-gemini"
    os.environ["GLM_MODEL"] = "test-glm"
    
    _ensure_global_ai_defaults(repo)

    repo.set_json.assert_called_once()
    key, payload = repo.set_json.call_args.args
    assert key == "global_ai_config"
    assert payload["primaryProvider"] == "glm"
    assert payload["primaryModel"] == "test-glm"
    assert payload["fallbackProvider"] == "gemini"
    assert payload["fallbackModel"] == "test-gemini"


def test_ensure_global_ai_defaults_skips_when_present():
    repo = MagicMock()
    repo.get_json.return_value = {"primaryProvider": "glm", "primaryModel": "existing-model"}

    _ensure_global_ai_defaults(repo)

    assert repo.set_json.call_count == 0
