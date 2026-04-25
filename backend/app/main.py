from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import thai_chat, emotion
from app.config import settings

app = FastAPI(
    title="AUDY Backend API",
    description="Thai chat and emotion classification API for AUDY learning app",
    version="1.1.0",
)

# CORS for Flutter app
# TODO: Replace with your Railway URL and custom domain when deployed
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "*",  # Allow all for development - restrict in production
        # "https://your-app.web.app",  # Flutter web app
        # "https://your-app.firebaseapp.com",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(thai_chat.router)
app.include_router(emotion.router)


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
