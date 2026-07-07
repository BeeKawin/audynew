import json
import random
import re
import uuid

from google import genai

from app.config import settings
from app.models.flashcard import (
    FlashcardCardValidation,
    FlashcardDifficulty,
    FlashcardLanguage,
    FlashcardSessionResponse,
    FlashcardValidationResponse,
    FlashcardWord,
)


WORD_COUNT_BY_DIFFICULTY: dict[FlashcardDifficulty, int] = {
    "easy": 3,
    "medium": 5,
    "hard": 7,
}


WORD_BANK: list[FlashcardWord] = [
    FlashcardWord(id="noun_ball", category="noun", en="ball", th="ลูกบอล"),
    FlashcardWord(id="noun_cat", category="noun", en="cat", th="แมว"),
    FlashcardWord(id="noun_dog", category="noun", en="dog", th="สุนัข"),
    FlashcardWord(id="noun_apple", category="noun", en="apple", th="แอปเปิล"),
    FlashcardWord(id="noun_child", category="noun", en="child", th="เด็ก"),
    FlashcardWord(id="noun_book", category="noun", en="book", th="หนังสือ"),
    FlashcardWord(id="noun_water", category="noun", en="water", th="น้ำ"),
    FlashcardWord(id="pronoun_i", category="pronoun", en="I", th="ฉัน"),
    FlashcardWord(id="pronoun_you", category="pronoun", en="you", th="คุณ"),
    FlashcardWord(id="pronoun_he", category="pronoun", en="he", th="เขา"),
    FlashcardWord(id="pronoun_she", category="pronoun", en="she", th="เธอ"),
    FlashcardWord(id="pronoun_we", category="pronoun", en="we", th="พวกเรา"),
    FlashcardWord(id="verb_see", category="verb", en="see", th="เห็น"),
    FlashcardWord(id="verb_like", category="verb", en="like", th="ชอบ"),
    FlashcardWord(id="verb_eat", category="verb", en="eat", th="กิน"),
    FlashcardWord(id="verb_read", category="verb", en="read", th="อ่าน"),
    FlashcardWord(id="verb_play", category="verb", en="play", th="เล่น"),
    FlashcardWord(id="verb_drink", category="verb", en="drink", th="ดื่ม"),
    FlashcardWord(id="adverb_now", category="adverb", en="now", th="ตอนนี้"),
    FlashcardWord(id="adverb_slowly", category="adverb", en="slowly", th="ช้าๆ"),
    FlashcardWord(id="adverb_quickly", category="adverb", en="quickly", th="เร็วๆ"),
    FlashcardWord(id="adverb_today", category="adverb", en="today", th="วันนี้"),
    FlashcardWord(id="adjective_red", category="adjective", en="red", th="สีแดง"),
    FlashcardWord(id="adjective_blue", category="adjective", en="blue", th="สีน้ำเงิน"),
    FlashcardWord(id="adjective_big", category="adjective", en="big", th="ใหญ่"),
    FlashcardWord(id="adjective_small", category="adjective", en="small", th="เล็ก"),
    FlashcardWord(id="adjective_happy", category="adjective", en="happy", th="มีความสุข"),
]


class FlashcardService:
    def __init__(self) -> None:
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        self.model = settings.GEMINI_MODEL
        self._words_by_id = {word.id: word for word in WORD_BANK}

    def create_session(
        self,
        language: FlashcardLanguage,
        difficulty: FlashcardDifficulty,
    ) -> FlashcardSessionResponse:
        word_count = WORD_COUNT_BY_DIFFICULTY[difficulty]
        target_ids = self._generate_target_ids(language, word_count)
        target_words = [self._words_by_id[word_id] for word_id in target_ids]
        distractors = self._pick_distractors(target_ids)
        hand_cards = [*target_words, *distractors]
        random.shuffle(hand_cards)

        return FlashcardSessionResponse(
            session_id=str(uuid.uuid4()),
            language=language,
            difficulty=difficulty,
            word_count=word_count,
            sentence_text=self._sentence_text(target_ids, language),
            target_card_ids=target_ids,
            hand_cards=hand_cards,
        )

    def validate(
        self,
        language: FlashcardLanguage,
        difficulty: FlashcardDifficulty,
        submitted_card_ids: list[str],
        available_card_ids: list[str],
        target_card_ids: list[str],
    ) -> FlashcardValidationResponse:
        unknown_ids = [
            card_id for card_id in submitted_card_ids if card_id not in self._words_by_id
        ]
        if unknown_ids:
            raise ValueError(f"Unknown card ids: {', '.join(unknown_ids)}")

        response = self._validate_with_llm(
            language=language,
            difficulty=difficulty,
            submitted_card_ids=submitted_card_ids,
            available_card_ids=available_card_ids,
            target_card_ids=target_card_ids,
        )
        if response is not None:
            return response

        return self._fallback_validate(submitted_card_ids, target_card_ids)

    def _generate_target_ids(
        self,
        language: FlashcardLanguage,
        word_count: int,
    ) -> list[str]:
        prompt = f"""
You generate sentence-card sequences for autistic children.
Return strict JSON only.

Language: {language}
Word count: {word_count}
Allowed word bank:
{self._word_bank_json()}

Rules:
- Use exactly {word_count} card ids.
- Use only ids from the word bank.
- Make a simple natural sentence or phrase for the requested language.
- Thai order may differ from English order.
- Do not create new words.

JSON shape:
{{"card_ids":["id_1","id_2"]}}
"""
        for _ in range(2):
            payload = self._call_json(prompt)
            ids = payload.get("card_ids") if isinstance(payload, dict) else None
            if self._ids_are_valid(ids, word_count):
                return ids

        return self._fallback_target_ids(word_count)

    def _validate_with_llm(
        self,
        language: FlashcardLanguage,
        difficulty: FlashcardDifficulty,
        submitted_card_ids: list[str],
        available_card_ids: list[str],
        target_card_ids: list[str],
    ) -> FlashcardValidationResponse | None:
        word_count = WORD_COUNT_BY_DIFFICULTY[difficulty]
        prompt = f"""
You validate sentence-card order for autistic children.
Return strict JSON only.

Language: {language}
Expected difficulty word count: {word_count}
Available card ids: {available_card_ids}
Original generated target ids: {target_card_ids}
Submitted card ids: {submitted_card_ids}
Word bank:
{self._word_bank_json()}

Rules:
- A valid answer does not need to exactly match the original target ids.
- It must be a simple natural sentence or phrase in {language}.
- It must only use submitted card ids from the word bank.
- Return one feedback item for every submitted card id, in submitted order.
- status is "correct" when the word can stay in this sequence.
- status is "swap" when the word is useful but should move.
- status is "remove" when the word does not belong.
- Keep message short and friendly.

JSON shape:
{{
  "is_valid": true,
  "feedback": [{{"card_id":"id","status":"correct"}}],
  "message": "Good sentence",
  "corrected_card_ids": ["optional","ids"]
}}
"""
        payload = self._call_json(prompt)
        if not isinstance(payload, dict):
            return None

        feedback = payload.get("feedback")
        if not isinstance(feedback, list) or len(feedback) != len(submitted_card_ids):
            return None

        allowed_statuses = {"correct", "swap", "remove"}
        parsed_feedback: list[FlashcardCardValidation] = []
        for item, expected_id in zip(feedback, submitted_card_ids):
            if not isinstance(item, dict):
                return None
            card_id = item.get("card_id")
            status = item.get("status")
            if card_id != expected_id or status not in allowed_statuses:
                return None
            parsed_feedback.append(
                FlashcardCardValidation(card_id=card_id, status=status)
            )

        corrected = payload.get("corrected_card_ids")
        if corrected is not None:
            if not isinstance(corrected, list) or any(
                card_id not in self._words_by_id for card_id in corrected
            ):
                corrected = None

        return FlashcardValidationResponse(
            is_valid=bool(payload.get("is_valid", False)),
            feedback=parsed_feedback,
            message=str(payload.get("message") or "Good try"),
            corrected_card_ids=corrected,
        )

    def _pick_distractors(self, target_ids: list[str]) -> list[FlashcardWord]:
        available = [word for word in WORD_BANK if word.id not in target_ids]
        random.shuffle(available)
        count = random.randint(2, 4)
        return available[:count]

    def _fallback_target_ids(self, word_count: int) -> list[str]:
        patterns = {
            3: ["pronoun_i", "verb_like", "noun_ball"],
            5: ["pronoun_i", "verb_see", "adjective_red", "noun_ball", "adverb_today"],
            7: [
                "pronoun_we",
                "verb_read",
                "adjective_big",
                "noun_book",
                "adverb_slowly",
                "adverb_today",
                "noun_child",
            ],
        }
        return patterns[word_count]

    def _fallback_validate(
        self,
        submitted_card_ids: list[str],
        target_card_ids: list[str],
    ) -> FlashcardValidationResponse:
        feedback: list[FlashcardCardValidation] = []
        for index, card_id in enumerate(submitted_card_ids):
            if index < len(target_card_ids) and target_card_ids[index] == card_id:
                status = "correct"
            elif card_id in target_card_ids:
                status = "swap"
            else:
                status = "remove"
            feedback.append(FlashcardCardValidation(card_id=card_id, status=status))

        is_valid = all(item.status == "correct" for item in feedback) and len(
            submitted_card_ids
        ) == len(target_card_ids)
        return FlashcardValidationResponse(
            is_valid=is_valid,
            feedback=feedback,
            message="Good sentence" if is_valid else "Try a small change",
            corrected_card_ids=target_card_ids,
        )

    def _sentence_text(self, card_ids: list[str], language: FlashcardLanguage) -> str:
        return " ".join(getattr(self._words_by_id[card_id], language) for card_id in card_ids)

    def _word_bank_json(self) -> str:
        return json.dumps([word.model_dump() for word in WORD_BANK], ensure_ascii=False)

    def _ids_are_valid(self, ids: object, word_count: int) -> bool:
        if not isinstance(ids, list) or len(ids) != word_count:
            return False
        return all(isinstance(card_id, str) and card_id in self._words_by_id for card_id in ids)

    def _call_json(self, prompt: str) -> dict | None:
        try:
            response = self.client.models.generate_content(
                model=self.model,
                contents=prompt,
                config={"max_output_tokens": 500, "temperature": 0.2},
            )
            text = response.text.strip()
            match = re.search(r"\{.*\}", text, flags=re.DOTALL)
            if not match:
                return None
            return json.loads(match.group(0))
        except Exception:
            return None


flashcard_service = FlashcardService()
