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
    # Actions (verbs)
    WordBankEntry("verb_eat", "verb", "eat", "กิน", "emoji:🍽️"),
    WordBankEntry("verb_drink", "verb", "drink", "ดื่ม", "emoji:🥤"),
    WordBankEntry("verb_sleep", "verb", "sleep", "นอน", "emoji:😴"),
    WordBankEntry("verb_walk", "verb", "walk", "เดิน", "emoji:🚶"),
    WordBankEntry("verb_run", "verb", "run", "วิ่ง", "emoji:🏃"),
    WordBankEntry("verb_play", "verb", "play", "เล่น", "emoji:🧸"),
    WordBankEntry("verb_read", "verb", "read", "อ่าน", "emoji:📖"),
    WordBankEntry("verb_write", "verb", "write", "เขียน", "emoji:📝"),
    WordBankEntry("verb_wash", "verb", "wash", "ล้าง", "emoji:🧼"),
    WordBankEntry("verb_open", "verb", "open", "เปิด", "emoji:🔓"),
    WordBankEntry("verb_close", "verb", "close", "ปิด", "emoji:🔒"),

    # Feelings (adjectives)
    WordBankEntry("adj_happy", "adjective", "happy", "ดีใจ", "emoji:😊"),
    WordBankEntry("adj_sad", "adjective", "sad", "เศร้า", "emoji:😢"),
    WordBankEntry("adj_hungry", "adjective", "hungry", "หิว", "emoji:😋"),
    WordBankEntry("adj_sleepy", "adjective", "sleepy", "ง่วง", "emoji:😴"),
    WordBankEntry("adj_hot", "adjective", "hot", "ร้อน", "emoji:🥵"),
    WordBankEntry("adj_cold", "adjective", "cold", "หนาว", "emoji:🥶"),

    # Places (nouns)
    WordBankEntry("noun_home", "noun", "home", "บ้าน", "emoji:🏠"),
    WordBankEntry("noun_school", "noun", "school", "โรงเรียน", "emoji:🏫"),
    WordBankEntry("noun_bathroom", "noun", "bathroom", "ห้องน้ำ", "emoji:🚽"),
    WordBankEntry("noun_kitchen", "noun", "kitchen", "ครัว", "emoji:🍳"),
    WordBankEntry("noun_garden", "noun", "garden", "สวน", "emoji:🌳"),
    WordBankEntry("noun_shop", "noun", "shop", "ร้านค้า", "emoji:🏪"),

    # Objects (nouns)
    WordBankEntry("noun_table", "noun", "table", "โต๊ะ", "emoji:🪵"),
    WordBankEntry("noun_chair", "noun", "chair", "เก้าอี้", "emoji:🪑"),
    WordBankEntry("noun_book", "noun", "book", "หนังสือ", "emoji:📚"),
    WordBankEntry("noun_pencil", "noun", "pencil", "ดินสอ", "emoji:✏️"),
    WordBankEntry("noun_glass", "noun", "glass", "แก้ว", "emoji:🥛"),
    WordBankEntry("noun_spoon", "noun", "spoon", "ช้อน", "emoji:🥄"),

    # Animals (nouns from directory)
    WordBankEntry("noun_bird", "noun", "bird", "นก", "assets/images/games/flashcard/animals/bird.png"),
    WordBankEntry("noun_cat", "noun", "cat", "แมว", "assets/images/games/flashcard/animals/cat.png"),
    WordBankEntry("noun_chicken", "noun", "chicken", "ไก่", "assets/images/games/flashcard/animals/chicken.png"),
    WordBankEntry("noun_cow", "noun", "cow", "วัว", "assets/images/games/flashcard/animals/cow.png"),
    WordBankEntry("noun_dog", "noun", "dog", "สุนัข", "assets/images/games/flashcard/animals/dog.png"),
    WordBankEntry("noun_elephant", "noun", "elephant", "ช้าง", "assets/images/games/flashcard/animals/elephant.png"),
    WordBankEntry("noun_goldfish", "noun", "goldfish", "ปลาทอง", "assets/images/games/flashcard/animals/gold-fish.png"),
    WordBankEntry("noun_goose", "noun", "goose", "ห่าน", "assets/images/games/flashcard/animals/goose.png"),
    WordBankEntry("noun_horse", "noun", "horse", "ม้า", "assets/images/games/flashcard/animals/horse.png"),
    WordBankEntry("noun_mouse", "noun", "mouse", "หนู", "assets/images/games/flashcard/animals/mouse.png"),
    WordBankEntry("noun_pig", "noun", "pig", "หมู", "assets/images/games/flashcard/animals/pig.png"),
    WordBankEntry("noun_rabbit", "noun", "rabbit", "กระต่าย", "assets/images/games/flashcard/animals/rabbit.png"),

    # Fruits (nouns from directory)
    WordBankEntry("noun_apple", "noun", "apple", "แอปเปิล", "assets/images/games/flashcard/fruits/apple.png"),
    WordBankEntry("noun_banana", "noun", "banana", "กล้วย", "assets/images/games/flashcard/fruits/banana.png"),
    WordBankEntry("noun_lime", "noun", "lime", "มะนาว", "assets/images/games/flashcard/fruits/lime.png"),
    WordBankEntry("noun_mango", "noun", "mango", "มะม่วง", "assets/images/games/flashcard/fruits/mango.png"),
    WordBankEntry("noun_orange", "noun", "orange", "ส้ม", "assets/images/games/flashcard/fruits/orange.png"),
    WordBankEntry("noun_pineapple", "noun", "pineapple", "สับปะรด", "assets/images/games/flashcard/fruits/pineapple.png"),
    WordBankEntry("noun_strawberry", "noun", "strawberry", "สตรอว์เบอร์รี", "assets/images/games/flashcard/fruits/strawberry.png"),
    WordBankEntry("noun_watermelon", "noun", "watermelon", "แตงโม", "assets/images/games/flashcard/fruits/watermelon.png"),

    # Vegetables (nouns from directory)
    WordBankEntry("noun_broccoli", "noun", "broccoli", "บรอกโคลี", "assets/images/games/flashcard/vetgetable/broccoli.png"),
    WordBankEntry("noun_carrot", "noun", "carrot", "แครอท", "assets/images/games/flashcard/vetgetable/carrot.png"),
    WordBankEntry("noun_corn", "noun", "corn", "ข้าวโพด", "assets/images/games/flashcard/vetgetable/corn.png"),
    WordBankEntry("noun_cucumber", "noun", "cucumber", "แตงกวา", "assets/images/games/flashcard/vetgetable/cucumber.png"),
    WordBankEntry("noun_mushroom", "noun", "mushroom", "เห็ด", "assets/images/games/flashcard/vetgetable/mushroom.png"),
    WordBankEntry("noun_potato", "noun", "potato", "มันฝรั่ง", "assets/images/games/flashcard/vetgetable/potato.png"),
    WordBankEntry("noun_pumpkin", "noun", "pumpkin", "ฟักทอง", "assets/images/games/flashcard/vetgetable/pumpkin.png"),
    WordBankEntry("noun_tomato", "noun", "tomato", "มะเขือเทศ", "assets/images/games/flashcard/vetgetable/tomato.png"),
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
        return f"""
You pick vocabulary word groups for autistic children to learn.
Return JSON only: {{"card_ids": ["..."]}}.
Pick exactly {word_count} card ids that belong to a meaningful group.
Good groups: animals together, fruits together, actions together, feelings together,
or a thematic mix like "kitchen items" or "things at school".
Use only ids from this word bank. Do not invent words or ids.
Word bank:
{json.dumps(bank, ensure_ascii=False)}
"""

    def _validate_with_llm(
        self,
        language: Language,
        target_ids: list[str],
        selected_ids: list[str],
    ) -> list[dict]:
        # Set-match validation: no LLM needed, use deterministic
        return self._deterministic_set_results(target_ids, selected_ids)

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
            3: ["noun_cat", "noun_dog", "noun_rabbit"],
            5: ["noun_apple", "noun_banana", "noun_mango", "noun_orange", "noun_lime"],
            7: [
                "verb_eat",
                "verb_drink",
                "verb_sleep",
                "verb_walk",
                "verb_run",
                "verb_play",
                "verb_read",
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

    def _deterministic_set_results(
        self,
        target_ids: list[str],
        selected_ids: list[str],
    ) -> list[dict]:
        target_set = set(target_ids)
        results = []
        for i, card_id in enumerate(selected_ids):
            if card_id in target_set:
                results.append({"card_id": card_id, "status": "correct", "current_index": i, "target_index": i})
            else:
                results.append({"card_id": card_id, "status": "remove", "current_index": i})
        return results

    def _deterministic_validation(
        self,
        language: Language,
        target_ids: list[str],
        selected_ids: list[str],
    ) -> FlashcardValidationResponse:
        target_set = set(target_ids)
        selected_set = set(selected_ids)
        is_correct = target_set == selected_set

        results: list[FlashcardValidationResult] = []
        for i, card_id in enumerate(selected_ids):
            if card_id in target_set:
                results.append(
                    FlashcardValidationResult(
                        card_id=card_id,
                        status="correct",
                        current_index=i,
                        target_index=i,
                    )
                )
            else:
                results.append(
                    FlashcardValidationResult(
                        card_id=card_id,
                        status="remove",
                        current_index=i,
                    )
                )

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
