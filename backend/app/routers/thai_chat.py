import logging

from fastapi import APIRouter, HTTPException
from app.models import ChatRequest, ChatResponse
from app.services.conversation_store import conversation_store
from app.services.gemini_client import social_chat_client
from datetime import datetime

router = APIRouter(prefix="/api", tags=["Social Chat"])
logger = logging.getLogger(__name__)


@router.post("/thai-chat", response_model=ChatResponse)
@router.post("/social-chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Send a message and receive an answer in the selected app language.

    Flow:
    1. Get or create session
    2. Get conversation context
    3. Generate response via Gemini
    4. Store message and response
    5. Return response
    """
    try:
        # Get or create session
        session_id = conversation_store.get_or_create_session(
            request.session_id, request.language
        )

        # Get conversation context
        context = conversation_store.get_context(session_id)

        # Generate response
        response = social_chat_client.generate_response(
            context=context,
            user_message=request.message,
            language=request.language,
        )

        # Store user message
        conversation_store.add_message(
            session_id=session_id, role="user", content=request.message
        )

        # Store assistant response
        conversation_store.add_message(
            session_id=session_id, role="assistant", content=response
        )

        return ChatResponse(
            session_id=session_id, response=response, timestamp=datetime.now()
        )

    except Exception as error:
        logger.warning("Social Chat request failed: %s", type(error).__name__)
        raise HTTPException(status_code=502, detail="Could not get a chat reply") from error


@router.get("/health")
async def health():
    """Health check endpoint."""
    return {"status": "ok"}
