from fastapi import FastAPI
from app.routers import thai_chat, emotion, tts, flashcard
from app.cors import configure_cors

app = FastAPI(
    title="AUDY Backend API",
    description="Thai chat and emotion classification API for AUDY learning app",
    version="1.1.0",
)

configure_cors(app)

# Include routers
app.include_router(thai_chat.router)
app.include_router(emotion.router)
app.include_router(tts.router)
app.include_router(flashcard.router)


@app.get("/")
async def root():
    return {
        "message": "AUDY Backend API",
        "version": "1.1.0",
        "endpoints": [
            "/api/health",
            "/api/thai-chat",
            "/api/emotion/classify",
            "/api/emotion/health",
            "/api/tts",
            "/api/tts/health",
            "/api/flashcard/round",
            "/api/flashcard/validate",
            "/api/flashcard/health",
        ],
    }


@app.get("/api/health")
async def health():
    """Overall API health check."""
    from app.services.emotion_service import get_emotion_service

    emotion_service = get_emotion_service()

    return {
        "status": "healthy",
        "emotion_service": emotion_service.is_ready(),
        "version": "1.1.0",
    }
