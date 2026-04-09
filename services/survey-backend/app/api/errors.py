from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
from app.domain.models.error_model import ApiError
from app.config.logging_config import logger

async def global_http_exception_handler(request: Request, exc: HTTPException):
    """
    Standardize all HTTPExceptions into the ApiError format.
    """
    # Extract request ID if available in headers
    request_id = request.headers.get("X-Request-ID")
    
    # Default values based on status code
    code = "INTERNAL_SERVER_ERROR"
    user_message = "Não foi possível completar esta ação agora. Tente novamente em alguns instantes."
    severity = "error"
    retryable = True

    if exc.status_code == 401:
        code = "UNAUTHORIZED"
        user_message = "Sessão expirada ou acesso não autorizado."
        retryable = True
    elif exc.status_code == 403:
        code = "FORBIDDEN"
        user_message = "Você não tem permissão para realizar esta ação."
        retryable = False
    elif exc.status_code == 404:
        code = "NOT_FOUND"
        user_message = "O recurso solicitado não foi encontrado."
        retryable = False
    elif exc.status_code == 422:
        code = "VALIDATION_FAILED"
        user_message = "Verifique os dados informados e tente novamente."
        retryable = True
    elif exc.status_code >= 500:
        severity = "critical"

    # If detail is already a dict (manually raised with ApiError structure)
    if isinstance(exc.detail, dict):
        detail_data = exc.detail
        error_payload = ApiError(
            code=detail_data.get("code", code),
            userMessage=detail_data.get("userMessage") or detail_data.get("user_message") or user_message,
            severity=detail_data.get("severity", severity),
            retryable=detail_data.get("retryable", retryable),
            requestId=request_id,
            operation=detail_data.get("operation"),
            stage=detail_data.get("stage"),
            details=detail_data.get("details")
        )
    else:
        # Simple string detail
        error_payload = ApiError(
            code=code,
            userMessage=user_message if exc.status_code >= 500 else str(exc.detail),
            severity=severity,
            retryable=retryable,
            requestId=request_id
        )

    return JSONResponse(
        status_code=exc.status_code,
        content=error_payload.model_dump(by_alias=True, exclude_none=True)
    )
