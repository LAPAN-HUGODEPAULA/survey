import os
from pydantic_settings import BaseSettings
from pydantic import computed_field
import logging

# Use basic logging here since logging_config may not be imported yet
config_logger = logging.getLogger("survey_app.config")

class Settings(BaseSettings):
    mongo_initdb_root_username: str
    mongo_initdb_root_password: str
    my_custom_env: str
    mongo_username: str = os.getenv("MONGO_USERNAME", "admin")
    mongo_password: str
    mail_username: str
    mail_password: str
    mail_server: str

    mongo_host: str = "localhost"
    mongo_uri_template: str = "mongodb://{mongo_username}:{mongo_password}@{mongo_host}:27017"
    
    # Allow direct override
    _mongodb_uri: str | None = None

    @computed_field
    @property
    def mongodb_uri(self) -> str:
        if self._mongodb_uri:
            return self._mongodb_uri
        
        # Check for env var override
        env_uri = os.getenv("MONGODB_URI") or os.getenv("MONGO_URI")
        if env_uri:
            return env_uri

        return self.mongo_uri_template.format(
            mongo_username=self.mongo_username,
            mongo_password=self.mongo_password,
            mongo_host=self.mongo_host
        )

    class Config:
        env_file = ".env"

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        config_logger.info("--- Loading System Settings ---")
        config_logger.info(f"MY_CUSTOM_ENV: {self.my_custom_env}")
        config_logger.info(f"MongoDB connection will use username: {self.mongo_username}")
        config_logger.info("MongoDB URI configured for host: mongodb:27017")
        config_logger.info(f"Mail username: {self.mail_username}")
        config_logger.info(f"Mail server: {self.mail_server}")
        config_logger.info("--- System Settings Loaded ---")

settings = Settings()
