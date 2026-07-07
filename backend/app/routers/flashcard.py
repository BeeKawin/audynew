from fastapi import APIRouter, HTTPException

from app.models.flashcard import (
    FlashcardSessionRequest,
    FlashcardSessionResponse,
    FlashcardValidationRequest,
    FlashcardValidationResponse,
)
from app.services.flashcard_service import flashcard_service

router = APIRouter(prefix="/api/flashcard", tags=["Flashcard"])


@router.post("/session", response_model=FlashcardSessionResponse)
async def create_flashcard_session(request: FlashcardSessionRequest):
    try:
        return flashcard_service.create_session(
            language=request.language,
            difficulty=request.difficulty,
        )
    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Flashcard session could not be created.",
        )


@router.post("/validate", response_model=FlashcardValidationResponse)
async def validate_flashcard_sentence(request: FlashcardValidationRequest):
    try:
        return flashcard_service.validate(
            language=request.language,
            difficulty=request.difficulty,
            submitted_card_ids=request.submitted_card_ids,
            available_card_ids=request.available_card_ids,
            target_card_ids=request.target_card_ids,
        )
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))
    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Flashcard answer could not be checked.",
        )
