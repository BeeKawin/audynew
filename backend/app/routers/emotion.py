"""
Emotion Classification Router.
Provides /api/emotion/classify endpoint for Flutter app.
"""

from fastapi import APIRouter, HTTPException, UploadFile, File
from app.services.emotion_service import get_emotion_service

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
            detail="Emotion classification service not available. Model not loaded.",
        )

    try:
        # Read image bytes
        image_bytes = await image.read()

        # Validate file size (max 10MB)
        if len(image_bytes) > 10 * 1024 * 1024:
            raise HTTPException(
                status_code=400, detail="Image too large. Maximum size is 10MB."
            )

        # Run classification
        result = service.classify(image_bytes)

        return result

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Classification failed: {str(e)}")


@router.get("/health")
async def emotion_health():
    """Check emotion service health."""
    service = get_emotion_service()
    return {
        "available": service.is_ready(),
        "error": service._load_error if not service.is_ready() else None,
    }
