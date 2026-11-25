from pydantic import BaseModel
from typing import Literal, Optional
from datetime import datetime


ChatLanguage = Literal["en", "th"]


class ChatRequest(BaseModel):
    session_id: Optional[str] = None  # None = new session
    message: str
    language: ChatLanguage = "th"


class ChatResponse(BaseModel):
    session_id: str
    response: str
    timestamp: datetime


class Message(BaseModel):
    role: str  # "user" or "assistant"
    content: str
    timestamp: datetime
