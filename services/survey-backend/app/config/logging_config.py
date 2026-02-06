import logging
import re


class _SensitiveDataFilter(logging.Filter):
    _patterns = [
        re.compile(r'(?i)(password|pwd|token|authorization|secret)\s*[:=]\s*[^\\s,;]+'),
        re.compile(r'(?i)("password"\s*:\s*")[^"]+(")'),
        re.compile(r'(?i)("token"\s*:\s*")[^"]+(")'),
        re.compile(r'(?i)Bearer\\s+[A-Za-z0-9\\-_.]+'),
    ]

    def filter(self, record: logging.LogRecord) -> bool:
        message = record.getMessage()
        for pattern in self._patterns:
            message = pattern.sub(self._redact_match, message)
        record.msg = message
        record.args = ()
        return True

    @staticmethod
    def _redact_match(match: re.Match) -> str:
        text = match.group(0)
        if text.lower().startswith("bearer "):
            return "Bearer ***"
        if ":" in text:
            key = text.split(":", 1)[0]
            return f"{key}: ***"
        if "=" in text:
            key = text.split("=", 1)[0]
            return f"{key}=***"
        return "***"

logger = logging.getLogger("survey-backend")
if not logger.handlers:
    handler = logging.StreamHandler()
    formatter = logging.Formatter(
        fmt="%(asctime)s %(levelname)s %(name)s %(message)s"
    )
    handler.setFormatter(formatter)
    handler.addFilter(_SensitiveDataFilter())
    logger.addHandler(handler)
logger.setLevel(logging.INFO)
