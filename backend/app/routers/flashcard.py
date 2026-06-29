from fastapi import APIRouter, HTTPException

from app.models import (
    GenerateRequest,
    GenerateResponse,
    ValidateRequest,
    ValidateResponse,
)
from app.services.flashcard_client import flashcard_client

router = APIRouter(prefix="/api/flashcard", tags=["Flashcard"])


@router.post("/generate", response_model=GenerateResponse)
async def generate(request: GenerateRequest):
    """Generate a target sentence, structure hint, and distractor cards."""
    try:
        data = flashcard_client.generate_round(
            difficulty=request.difficulty, language=request.language
        )
        return GenerateResponse(**data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/validate", response_model=ValidateResponse)
async def validate(request: ValidateRequest):
    """Validate a user sentence (meaning-equivalent) with word-level error flags."""
    try:
        data = flashcard_client.validate(
            words=request.words,
            pos_tags=request.pos_tags,
            target_context=request.target_context,
            language=request.language,
        )
        return ValidateResponse(**data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/health")
async def health():
    """Flashcard AI health check."""
    return {"status": "ok", "model": flashcard_client.model}
