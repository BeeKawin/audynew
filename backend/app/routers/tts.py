import logging

from fastapi import APIRouter, HTTPException
from fastapi.responses import Response
from pydantic import BaseModel

from app.services.tts_service import tts_service
from app.models.chat import ChatLanguage

router = APIRouter(prefix="/api/tts", tags=["Text-to-Speech"])
logger = logging.getLogger(__name__)


class TTSRequest(BaseModel):
    """Request body for text-to-speech generation."""
    text: str
    language: ChatLanguage = "th"


@router.post("")
async def generate_speech(request: TTSRequest):
    """
    Generate speech using Gemini TTS in the selected language.
    
    Returns WAV audio data that can be played directly.
    
    Args:
        request: JSON body with "text" field containing Thai text
        
    Returns:
        audio/wav response with synthesized speech
        
    Raises:
        HTTPException: If TTS generation fails
    """
    try:
        # Generate speech
        wav_bytes = await tts_service.generate_speech(request.text, request.language)
        
        # Return as WAV audio
        return Response(
            content=wav_bytes,
            media_type="audio/wav",
            headers={
                "Content-Disposition": "inline; filename=speech.wav"
            }
        )
        
    except Exception as error:
        logger.warning("TTS request failed: %s", type(error).__name__)
        raise HTTPException(
            status_code=502, detail="Could not generate speech"
        ) from error


@router.get("/health")
async def tts_health():
    """Check if TTS service is available (API key configured)."""
    from app.config import settings
    
    return {
        "status": "available" if settings.GEMINI_API_KEY else "unavailable",
        "message": "GEMINI_API_KEY configured" if settings.GEMINI_API_KEY else "GEMINI_API_KEY not set"
    }
