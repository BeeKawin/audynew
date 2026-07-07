import json
import uuid
from dataclasses import dataclass
from typing import Literal

from app.config import settings
from app.models.flashcard import (
    FlashcardCard,
    FlashcardRoundResponse,
    FlashcardValidationResponse,
    FlashcardValidationResult,
)
from app.services.gemini_client import ThaiChatClient


Language = Literal["en", "th"]
Category = Literal["noun", "pronoun", "verb", "adverb", "adjective"]


@dataclass(frozen=True)
class WordBankEntry:
    id: str
    category: Category
    en: str
    th: str
    image_asset: str


WORD_BANK: tuple[WordBankEntry, ...] = (
    WordBankEntry("noun_apple", "noun", "apple", "แอปเปิล", "assets/images/sorting/apple.png"),
    WordBankEntry("noun_ball", "noun", "ball", "ลูกบอล", "assets/images/sorting/ball.png"),
    WordBankEntry("noun_dog", "noun", "dog", "สุนัข", "assets/images/sorting/dog.png"),
    WordBankEntry("noun_cat", "noun", "cat", "แมว", "assets/images/sorting/cat.png"),
    WordBankEntry("noun_book", "noun", "book", "หนังสือ", "assets/images/sorting/book.png"),
    WordBankEntry("noun_cup", "noun", "cup", "แก้ว", "assets/images/sorting/cup.png"),
    WordBankEntry("pronoun_i", "pronoun", "I", "ฉัน", "assets/mascot/Neutral.png"),
    WordBankEntry("pronoun_you", "pronoun", "you", "เธอ", "assets/mascot/Neutral.png"),
    WordBankEntry("pronoun_we", "pronoun", "we", "เรา", "assets/mascot/Heart.png"),
    WordBankEntry("pronoun_he", "pronoun", "he", "เขา", "assets/mascot/Neutral.png"),
    WordBankEntry("pronoun_she", "pronoun", "she", "เธอ", "assets/mascot/Sparkles.png"),
    WordBankEntry("verb_eat", "verb", "eat", "กิน", "assets/images/sorting/spoon.png"),
    WordBankEntry("verb_see", "verb", "see", "เห็น", "assets/images/sorting/circle.png"),
    WordBankEntry("verb_like", "verb", "like", "ชอบ", "assets/mascot/Heart.png"),
    WordBankEntry("verb_want", "verb", "want", "อยากได้", "assets/images/sorting/bag.png"),
    WordBankEntry("verb_read", "verb", "read", "อ่าน", "assets/images/sorting/book.png"),
    WordBankEntry("verb_play", "verb", "play", "เล่น", "assets/images/sorting/toy.png"),
    WordBankEntry("adverb_fast", "adverb", "fast", "เร็ว", "assets/images/sorting/star.png"),
    WordBankEntry("adverb_slowly", "adverb", "slowly", "ช้าๆ", "assets/images/sorting/turtle.png"),
    WordBankEntry("adverb_now", "adverb", "now", "ตอนนี้", "assets/images/sorting/dot.png"),
    WordBankEntry("adverb_here", "adverb", "here", "ที่นี่", "assets/images/sorting/circle.png"),
    WordBankEntry("adjective_red", "adjective", "red", "สีแดง", "assets/images/sorting/circle.png"),
    WordBankEntry("adjective_big", "adjective", "big", "ใหญ่", "assets/images/sorting/ball.png"),
    WordBankEntry("adjective_small", "adjective", "small", "เล็ก", "assets/images/sorting/dot.png"),
    WordBankEntry("adjective_happy", "adjective", "happy", "มีความสุข", "assets/images/sorting/happy.png"),
    WordBankEntry("adjective_soft", "adjective", "soft", "นุ่ม", "assets/images/sorting/towel.png"),
)

ENTRY_BY_ID = {entry.id: entry for entry in WORD_BANK}


class FlashcardService:
    def __init__(self):
        self.client = ThaiChatClient().client
        self.model = settings.GEMINI_MODEL
        self._round_targets: dict[str, list[str]] = {}

    def generate_round(self, language: Language, word_count: int) -> FlashcardRoundResponse:
        target_ids = self._generate_target_ids(language, word_count)
        round_id = str(uuid.uuid4())
        self._round_targets[round_id] = target_ids
        return self._build_round_response(round_id, language, word_count, target_ids)

    def validate(
        self,
        round_id: str,
        language: Language,
        target_card_ids: list[str],
        selected_card_ids: list[str],
    ) -> FlashcardValidationResponse:
        target_ids = self._round_targets.get(round_id) or target_card_ids
        target_ids = [card_id for card_id in target_ids if card_id in ENTRY_BY_ID]
        selected_ids = [card_id for card_id in selected_card_ids if card_id in ENTRY_BY_ID]

        if not target_ids:
            return self._deterministic_validation(language, [], selected_ids)

        try:
            llm_results = self._validate_with_llm(language, target_ids, selected_ids)
            if self._validation_is_usable(llm_results, selected_ids):
                is_correct = all(item["status"] == "correct" for item in llm_results)
                return FlashcardValidationResponse(
                    is_correct=is_correct,
                    feedback=self._feedback(language, is_correct),
                    results=[
                        FlashcardValidationResult(
                            card_id=item["card_id"],
                            status=item["status"],
                            current_index=item["current_index"],
                            target_index=item.get("target_index"),
                        )
                        for item in llm_results
                    ],
                )
        except Exception:
            pass

        return self._deterministic_validation(language, target_ids, selected_ids)

    def _generate_target_ids(self, language: Language, word_count: int) -> list[str]:
        prompt = self._generation_prompt(language, word_count)
        for _ in range(2):
            try:
                response = self.client.models.generate_content(
                    model=self.model,
                    contents=prompt,
                    config={
                        "temperature": 0.4,
                        "max_output_tokens": 200,
                        "response_mime_type": "application/json",
                    },
                )
                data = json.loads(response.text or "{}")
                ids = data.get("card_ids", [])
                if self._target_ids_are_valid(ids, word_count):
                    return ids
            except Exception:
                continue

        return self._fallback_target_ids(word_count)

    def _generation_prompt(self, language: Language, word_count: int) -> str:
        bank = [
            {
                "id": entry.id,
                "category": entry.category,
                "en": entry.en,
                "th": entry.th,
            }
            for entry in WORD_BANK
        ]
        language_name = "Thai" if language == "th" else "English"
        return f"""
You generate flashcard sentences for autistic children.
Return JSON only: {{"card_ids": ["..."]}}.
Use exactly {word_count} card ids.
Use only ids from this word bank. Do not invent words or ids.
The sentence must be natural enough in {language_name}.
For Thai, use Thai word order. For English, use English word order.
Word bank:
{json.dumps(bank, ensure_ascii=False)}
"""

    def _validate_with_llm(
        self,
        language: Language,
        target_ids: list[str],
        selected_ids: list[str],
    ) -> list[dict]:
        target_words = self._words_for_ids(target_ids, language)
        selected_words = self._words_for_ids(selected_ids, language)
        prompt = f"""
Validate a child-built flashcard sentence.
Return JSON only: {{"results":[{{"card_id":"id","status":"correct|move|remove","current_index":0,"target_index":0}}]}}.
Mark correct if a selected card is already at the correct index.
Mark move if the card belongs in the sentence but is at a different index.
Mark remove if the selected card is not needed.
Use every selected card exactly once in results.
Target ids: {target_ids}
Target words: {target_words}
Selected ids: {selected_ids}
Selected words: {selected_words}
Language: {language}
"""
        response = self.client.models.generate_content(
            model=self.model,
            contents=prompt,
            config={
                "temperature": 0.1,
                "max_output_tokens": 240,
                "response_mime_type": "application/json",
            },
        )
        data = json.loads(response.text or "{}")
        return data.get("results", [])

    def _target_ids_are_valid(self, ids: list[str], word_count: int) -> bool:
        return (
            isinstance(ids, list)
            and len(ids) == word_count
            and len(set(ids)) == len(ids)
            and all(card_id in ENTRY_BY_ID for card_id in ids)
        )

    def _validation_is_usable(self, results: list[dict], selected_ids: list[str]) -> bool:
        if len(results) != len(selected_ids):
            return False
        result_ids = [item.get("card_id") for item in results]
        if sorted(result_ids) != sorted(selected_ids):
            return False
        valid_statuses = {"correct", "move", "remove"}
        return all(item.get("status") in valid_statuses for item in results)

    def _fallback_target_ids(self, word_count: int) -> list[str]:
        templates = {
            3: ["adjective_red", "noun_ball", "adverb_here"],
            5: ["pronoun_i", "verb_see", "adjective_red", "noun_ball", "adverb_now"],
            7: [
                "pronoun_we",
                "verb_like",
                "adjective_big",
                "noun_book",
                "adverb_here",
                "verb_read",
                "adverb_slowly",
            ],
        }
        return templates[word_count]

    def _build_round_response(
        self,
        round_id: str,
        language: Language,
        word_count: int,
        target_ids: list[str],
    ) -> FlashcardRoundResponse:
        cards = [self._card_for_entry(ENTRY_BY_ID[card_id], language) for card_id in target_ids]
        return FlashcardRoundResponse(
            round_id=round_id,
            language=language,
            word_count=word_count,
            sentence_text=" ".join(card.display_text for card in cards),
            cards=cards,
            target_card_ids=target_ids,
        )

    def _card_for_entry(self, entry: WordBankEntry, language: Language) -> FlashcardCard:
        text = entry.th if language == "th" else entry.en
        return FlashcardCard(
            id=entry.id,
            category=entry.category,
            display_text=text,
            tts_text=text,
            image_asset=entry.image_asset,
            language=language,
        )

    def _words_for_ids(self, ids: list[str], language: Language) -> list[str]:
        return [
            ENTRY_BY_ID[card_id].th if language == "th" else ENTRY_BY_ID[card_id].en
            for card_id in ids
            if card_id in ENTRY_BY_ID
        ]

    def _deterministic_validation(
        self,
        language: Language,
        target_ids: list[str],
        selected_ids: list[str],
    ) -> FlashcardValidationResponse:
        results: list[FlashcardValidationResult] = []
        for current_index, card_id in enumerate(selected_ids):
            if current_index < len(target_ids) and target_ids[current_index] == card_id:
                results.append(
                    FlashcardValidationResult(
                        card_id=card_id,
                        status="correct",
                        current_index=current_index,
                        target_index=current_index,
                    )
                )
            elif card_id in target_ids:
                results.append(
                    FlashcardValidationResult(
                        card_id=card_id,
                        status="move",
                        current_index=current_index,
                        target_index=target_ids.index(card_id),
                    )
                )
            else:
                results.append(
                    FlashcardValidationResult(
                        card_id=card_id,
                        status="remove",
                        current_index=current_index,
                    )
                )

        is_correct = selected_ids == target_ids
        return FlashcardValidationResponse(
            is_correct=is_correct,
            feedback=self._feedback(language, is_correct),
            results=results,
        )

    def _feedback(self, language: Language, is_correct: bool) -> str:
        if language == "th":
            return "ถูกต้อง" if is_correct else "ลองจัดการ์ดใหม่นะ"
        return "Correct" if is_correct else "Try moving the cards"


flashcard_service = FlashcardService()
