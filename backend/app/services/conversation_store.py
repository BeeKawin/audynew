from typing import Dict, List, Optional
from datetime import datetime, timedelta
from app.models import Message
from app.config import settings


class ConversationStore:
    """
    In-memory conversation storage.
    For production, replace with Redis or database.
    """

    def __init__(self):
        self._store: Dict[str, List[Message]] = {}
        self._last_activity: Dict[str, datetime] = {}

    def get_or_create_session(self, session_id: Optional[str] = None) -> str:
        """Get existing session or create new one."""
        import uuid

        if session_id and session_id in self._store:
            self._last_activity[session_id] = datetime.now()
            return session_id

        new_id = str(uuid.uuid4())
        self._store[new_id] = []
        self._last_activity[new_id] = datetime.now()
        return new_id

    def add_message(self, session_id: str, role: str, content: str) -> None:
        """Add message to session history."""
        if session_id not in self._store:
            self._store[session_id] = []

        self._store[session_id].append(
            Message(role=role, content=content, timestamp=datetime.now())
        )
        self._last_activity[session_id] = datetime.now()

        # Keep only last N messages
        if len(self._store[session_id]) > settings.MAX_CONTEXT_MESSAGES:
            self._store[session_id] = self._store[session_id][
                -settings.MAX_CONTEXT_MESSAGES :
            ]

    def get_context(self, session_id: str) -> List[Message]:
        """Get conversation context for session."""
        self._cleanup_expired()
        return self._store.get(session_id, [])

    def _cleanup_expired(self) -> None:
        """Remove expired sessions."""
        now = datetime.now()
        timeout = timedelta(minutes=settings.SESSION_TIMEOUT_MINUTES)

        expired = [
            sid
            for sid, last_time in self._last_activity.items()
            if now - last_time > timeout
        ]

        for sid in expired:
            self._store.pop(sid, None)
            self._last_activity.pop(sid, None)


# Global instance
conversation_store = ConversationStore()
