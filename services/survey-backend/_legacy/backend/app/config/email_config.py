from fastapi_mail import FastMail, MessageSchema, ConnectionConfig
from pydantic import EmailStr, SecretStr
from typing import List
from .system_settings import settings
from .logging_config import logger
    
logger.info("--- Creating Email Connection Config ---")
conf = ConnectionConfig(
    MAIL_USERNAME = settings.mail_username,
    MAIL_PASSWORD = SecretStr(settings.mail_password),
    MAIL_FROM = settings.mail_username,
    MAIL_PORT = 587,
    MAIL_SERVER = settings.mail_server,
    MAIL_STARTTLS = True,
    MAIL_SSL_TLS = False,
    USE_CREDENTIALS = True,
    VALIDATE_CERTS = True
)
logger.info("Email connection config created for server: %s, port: %d", conf.MAIL_SERVER, conf.MAIL_PORT)
logger.info("--- Email Connection Config Created ---")

fast_mail = FastMail(conf)
logger.info("FastMail instance created")
