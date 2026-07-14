from pydantic import BaseModel, Field
from typing import Literal, Optional


FlashcardLanguage = Literal["en", "th"]
FlashcardCategory = Literal["noun", "pronoun", "verb", "adverb", "adjective", "preposition", "determiner", "conjunction"]
FlashcardStatus = Literal["correct", "move", "remove"]


class FlashcardRoundRequest(BaseModel):
    language: FlashcardLanguage = "en"
    word_count: Literal[3, 5, 7] = 3
    custom_cards: Optional[list[dict]] = None


class FlashcardCard(BaseModel):
    id: str
    category: FlashcardCategory
    display_text: str
    tts_text: str
    image_asset: str
    language: FlashcardLanguage


class FlashcardRoundResponse(BaseModel):
    round_id: str
    language: FlashcardLanguage
    word_count: int
    sentence_text: str
    cards: list[FlashcardCard]
    target_card_ids: list[str]


class FlashcardValidationRequest(BaseModel):
    round_id: str
    language: FlashcardLanguage = "en"
    target_card_ids: list[str] = Field(default_factory=list)
    selected_card_ids: list[str]
    custom_cards: Optional[list[dict]] = None


class FlashcardValidationResult(BaseModel):
    card_id: str
    status: FlashcardStatus
    current_index: int
    target_index: Optional[int] = None


class FlashcardValidationResponse(BaseModel):
    is_correct: bool
    feedback: str
    results: list[FlashcardValidationResult]

