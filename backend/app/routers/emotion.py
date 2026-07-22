"""Emotion classification endpoints for the Flutter app."""

import logging

from fastapi import APIRouter, File, HTTPException, UploadFile

from app.services.emotion_service import get_emotion_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/emotion", tags=["Emotion Classification"])


@router.post("/classify")
async def classify_emotion(image: UploadFile = File(...)):
    """
    Classify emotion from uploaded image.

    Args:
        image: Image file (JPEG/PNG)

    Returns:
        {
            "detected_emotion": str,
            "confidence": float,
            "is_confident": bool,
            "model_label": str,
            "all_probabilities": dict
        }
    """
    service = get_emotion_service()

    if not service.is_ready():
        raise HTTPException(
            status_code=503,
            detail="Emotion detection is temporarily unavailable.",
        )

    try:
        image_bytes = await image.read()

        if not image_bytes:
            raise HTTPException(status_code=400, detail="The uploaded image is empty.")

        if len(image_bytes) > 10 * 1024 * 1024:
            raise HTTPException(
                status_code=400, detail="Image too large. Maximum size is 10MB."
            )

        return service.classify(image_bytes)

    except HTTPException:
        raise
    except Exception:
        logger.exception("Emotion classification failed")
        raise HTTPException(
            status_code=422,
            detail="The image could not be processed. Please take another photo.",
        ) from None


@router.get("/health")
async def emotion_health():
    """Check emotion service health."""
    service = get_emotion_service()
    return {
        "available": service.is_ready(),
        "error": service._load_error if not service.is_ready() else None,
    }
