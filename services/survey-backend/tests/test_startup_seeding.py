import os
from unittest.mock import MagicMock
from app.main import _ensure_ai_model_defaults


def test_ensure_ai_model_defaults_seeds_when_missing():
    repo = MagicMock()
    repo.get_value.return_value = None
    
    # Mock environment variables
    os.environ["GEMINI_MODEL"] = "test-gemini"
    os.environ["GLM_MODEL"] = "test-glm"
    
    _ensure_ai_model_defaults(repo)
    
    repo.set_value.assert_any_call("ai_default_gemini_model", "test-gemini")
    repo.set_value.assert_any_call("ai_default_glm_model", "test-glm")


def test_ensure_ai_model_defaults_skips_when_present():
    repo = MagicMock()
    repo.get_value.side_effect = lambda key: "existing" if key in ["ai_default_gemini_model", "ai_default_glm_model"] else None
    
    _ensure_ai_model_defaults(repo)
    
    assert repo.set_value.call_count == 0
