from fastapi import APIRouter, HTTPException

from app.models.flashcard import (
    FlashcardRoundRequest,
    FlashcardRoundResponse,
    FlashcardValidationRequest,
    FlashcardValidationResponse,
)
from app.services.flashcard_service import flashcard_service

router = APIRouter(prefix="/api/flashcard", tags=["Flashcard"])


@router.post("/round", response_model=FlashcardRoundResponse)
async def generate_round(request: FlashcardRoundRequest):
    try:
        return flashcard_service.generate_round(
            language=request.language,
            word_count=request.word_count,
            custom_cards=request.custom_cards,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Round generation failed: {e}")


@router.post("/validate", response_model=FlashcardValidationResponse)
async def validate_round(request: FlashcardValidationRequest):
    try:
        return flashcard_service.validate(
            round_id=request.round_id,
            language=request.language,
            target_card_ids=request.target_card_ids,
            selected_card_ids=request.selected_card_ids,
            custom_cards=request.custom_cards,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Validation failed: {e}")


@router.get("/health")
async def health():
    return {"status": "ok"}

