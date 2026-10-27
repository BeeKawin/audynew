import os
from dotenv import load_dotenv

load_dotenv()


class Settings:
    # Exact origins, comma separated. Native clients do not send an Origin.
    CORS_ORIGINS: list[str] = [
        value.strip() for value in os.getenv(
            "CORS_ORIGINS", "http://localhost:8080,http://127.0.0.1:8080"
        ).split(",") if value.strip()
    ]
    CORS_ORIGIN_REGEX: str | None = os.getenv("CORS_ORIGIN_REGEX") or None
    EMOTION_MODEL_ENABLED: bool = os.getenv("EMOTION_MODEL_ENABLED", "false").lower() == "true"
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "")
    GEMINI_MODEL: str = os.getenv("GEMINI_MODEL", "gemini-2.5-flash-lite")
    MAX_CONTEXT_MESSAGES: int = int(os.getenv("MAX_CONTEXT_MESSAGES", "10"))
    SESSION_TIMEOUT_MINUTES: int = int(os.getenv("SESSION_TIMEOUT_MINUTES", "30"))
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))


settings = Settings()
