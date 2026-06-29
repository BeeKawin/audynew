from pydantic import BaseModel
from typing import List, Optional


# ---- Shared card shape ----
class FlashWord(BaseModel):
    word: str  # canonical English (drives glyph + grammar)
    pos: str  # noun | pronoun | verb | adjective | adverb | preposition
    glyph: Optional[str] = None  # emoji; resolved client-side if missing
    word_th: Optional[str] = None  # Thai display text (shown in Thai mode)


# ---- /api/flashcard/generate ----
class GenerateRequest(BaseModel):
    difficulty: str = "easy"  # easy | medium | hard
    language: str = "en"      # en | th


class GenerateResponse(BaseModel):
    sentence: List[FlashWord]      # target valid order
    structure: List[str]          # POS order -> ghost-slot hints
    distractors: List[FlashWord]  # extra tempting wrong cards


# ---- /api/flashcard/validate ----
class ValidateRequest(BaseModel):
    words: List[str]                 # user's placed words, left -> right
    pos_tags: Optional[List[str]] = None
    target_context: Optional[str] = None  # instruction / target sentence hint
    language: str = "en"


class WordError(BaseModel):
    index: int     # 0-based index into `words`
    reason: str


class ValidateResponse(BaseModel):
    valid: bool                    # meaning-equivalent, not exact-match
    errors: List[WordError] = []   # word-level flags -> drive red glow
    swap_index: Optional[int] = None  # the single card the child should move
    feedback: str = ""             # short child-friendly message
