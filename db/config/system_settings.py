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
    mongo_password: str = os.getenv("MONGO_PASSWORD", "secret")
    mail_username: str = os.getenv("MAIL_USERNAME", "email@not.set")
    mail_password: str = os.getenv("MAIL_PASSWORD", "nopassword")
    mail_server: str = os.getenv("MAIL_SERVER", "smtp.example.com")

    @computed_field
    @property
    def mongodb_uri(self) -> str:
        # return f"mongodb://{self.mongo_username}:{self.mongo_password}@mongodb:27017"
        return f"mongodb+srv://{self.mongo_username}:{self.mongo_password}@lapan.xttqjbk.mongodb.net/?retryWrites=true&w=majority&appName=Lapan"

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
