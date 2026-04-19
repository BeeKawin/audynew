from fastapi import APIRouter, HTTPException
from app.models import ChatRequest, ChatResponse
from app.services.conversation_store import conversation_store
from app.services.gemini_client import thai_chat_client
from datetime import datetime

router = APIRouter(prefix="/api", tags=["Thai Chat"])


@router.post("/thai-chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Send message and receive Thai response.

    Flow:
    1. Get or create session
    2. Get conversation context
    3. Generate response via Gemini
    4. Store message and response
    5. Return response
    """
    try:
        # Get or create session
        session_id = conversation_store.get_or_create_session(request.session_id)

        # Get conversation context
        context = conversation_store.get_context(session_id)

        # Generate response
        response = thai_chat_client.generate_response(
            context=context, user_message=request.message
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

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/health")
async def health():
    """Health check endpoint."""
    return {"status": "ok"}
