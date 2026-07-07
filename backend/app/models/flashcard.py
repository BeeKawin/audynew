from typing import Literal, Optional

from pydantic import BaseModel, Field


FlashcardLanguage = Literal["en", "th"]
FlashcardDifficulty = Literal["easy", "medium", "hard"]
FlashcardCategory = Literal["noun", "pronoun", "verb", "adverb", "adjective"]
FlashcardValidationStatus = Literal["correct", "swap", "remove"]


class FlashcardWord(BaseModel):
    id: str
    category: FlashcardCategory
    en: str
    th: str


class FlashcardSessionRequest(BaseModel):
    language: FlashcardLanguage
    difficulty: FlashcardDifficulty


class FlashcardSessionResponse(BaseModel):
    session_id: str
    language: FlashcardLanguage
    difficulty: FlashcardDifficulty
    word_count: int
    sentence_text: str
    target_card_ids: list[str]
    hand_cards: list[FlashcardWord]


class FlashcardValidationRequest(BaseModel):
    language: FlashcardLanguage
    difficulty: FlashcardDifficulty
    submitted_card_ids: list[str] = Field(min_length=1)
    available_card_ids: list[str] = Field(default_factory=list)
    target_card_ids: list[str] = Field(default_factory=list)


class FlashcardCardValidation(BaseModel):
    card_id: str
    status: FlashcardValidationStatus


class FlashcardValidationResponse(BaseModel):
    is_valid: bool
    feedback: list[FlashcardCardValidation]
    message: str
    corrected_card_ids: Optional[list[str]] = None
