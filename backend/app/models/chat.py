from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class ChatRequest(BaseModel):
    session_id: Optional[str] = None  # None = new session
    message: str


class ChatResponse(BaseModel):
    session_id: str
    response: str
    timestamp: datetime


class Message(BaseModel):
    role: str  # "user" or "assistant"
    content: str
    timestamp: datetime
