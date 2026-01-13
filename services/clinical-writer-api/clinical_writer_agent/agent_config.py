"""
Configuration file for Clinical Writer AI Multiagent System.
"""

import os
from pathlib import Path
from dotenv import load_dotenv
from langchain_google_genai import ChatGoogleGenerativeAI

# Load environment variables from .env file
load_dotenv()


class AgentConfig:
    """Centralized configuration for the Clinical Writer Agent"""

    # ========================
    # API Configuration
    # ========================
    GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

    # ========================
    # LLM Model Configuration
    # ========================
    LLM_MODEL_NAME = "gemini-2.5-flash-lite"
    PRIMARY_MODEL = os.getenv("PRIMARY_MODEL", LLM_MODEL_NAME)
    FALLBACK_MODEL = os.getenv("FALLBACK_MODEL")
    LLM_TEMPERATURE = 0.3

    # ========================
    # File Paths Configuration
    # ========================
    # Get the directory where this config file is located
    BASE_DIR = Path(__file__).parent
    BAD_WORDS_FILE = BASE_DIR / "repository/bad_word.txt"
    SLANGS_FILE = BASE_DIR / "repository/slangs.txt"

    # ========================
    # Input Validation Configuration
    # ========================
    # Emoji detection pattern ranges
    EMOJI_UNICODE_RANGES = [
        "\U0001f600-\U0001f64f",  # emoticons
        "\U0001f300-\U0001f5ff",  # symbols & pictographs
        "\U0001f680-\U0001f6ff",  # transport & map symbols
        "\U0001f1e0-\U0001f1ff",  # flags (iOS)
        "\U00002702-\U000027b0",  # Dingbats
        "\U000024c2-\U0001f251",
    ]

    # Markup detection pattern
    MARKUP_PATTERN = r"<[^>]*>|&[a-z]+;"  # Basic HTML/XML tags and entities

    # Advertisement keywords (multilingual support)
    AD_KEYWORDS = [
        "buy now",
        "discount",
        "limited offer",
        "click here",
        "inscreva-se",
        "compre agora",
        "oferta limitada",
        "clique aqui",
    ]

    # JSON classification keywords
    JSON_CLASSIFICATION_KEYS = ["patient", "surveyId"]

    # Conversation classification keywords
    CONVERSATION_KEYWORDS = ["doutor", "paciente", "dr."]

    # LLM judge configuration
    JUDGE_APPROPRIATENESS_THRESHOLD = 0.5

    # ========================
    # Error Messages Configuration
    # ========================
    ERROR_MSG_API_KEY_MISSING = "GEMINI_API_KEY not found in environment variables."
    ERROR_MSG_INAPPROPRIATE_CONTENT = "Input content flagged as inappropriate."
    ERROR_MSG_UNCLASSIFIED_INPUT = "Input content could not be classified as conversation or JSON. Please provide a valid input."
    ERROR_MSG_MEDICAL_RECORD_GENERATION = "Error generating medical record: {error}"
    ERROR_MSG_NO_ERROR_AVAILABLE = "No error message available"

    # ========================
    # Classification Types
    # ========================
    CLASSIFICATION_CONVERSATION = "conversation"
    CLASSIFICATION_JSON = "json"
    CLASSIFICATION_FLAGGED = "flagged_inappropriate"
    CLASSIFICATION_INAPPROPRIATE = (
        "flagged_inappropriate"  # Alias for backward compatibility
    )
    CLASSIFICATION_OTHER = "other"
    CLASSIFICATION_VALIDATED = "validated"
    CLASSIFICATION_STRATEGY_FACTORIES: list = []

    @classmethod
    def validate_config(
        cls,
        *,
        gemini_api_key: str | None = None,
        bad_words_file: Path | None = None,
        slangs_file: Path | None = None,
    ):
        """Validate that all required configuration is present."""
        api_key = gemini_api_key or cls.GEMINI_API_KEY
        if not api_key:
            raise ValueError(cls.ERROR_MSG_API_KEY_MISSING)

        bad_words_path = bad_words_file or cls.BAD_WORDS_FILE
        if not bad_words_path.exists():
            raise FileNotFoundError(f"Bad words file not found: {bad_words_path}")

        slangs_path = slangs_file or cls.SLANGS_FILE
        if not slangs_path.exists():
            raise FileNotFoundError(f"Slangs file not found: {slangs_path}")

    @classmethod
    def create_llm_instance(
        cls,
        *,
        api_key: str | None = None,
        model: str | None = None,
        temperature: float | None = None,
    ):
        """Factory method to create a configured LLM instance."""
        resolved_api_key = api_key or cls.GEMINI_API_KEY
        resolved_model = model or cls.LLM_MODEL_NAME
        resolved_temperature = (
            temperature if temperature is not None else cls.LLM_TEMPERATURE
        )

        cls.validate_config(gemini_api_key=resolved_api_key)
        return ChatGoogleGenerativeAI(
            model=resolved_model,
            temperature=resolved_temperature,
            api_key=resolved_api_key,
        )
