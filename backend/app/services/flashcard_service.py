import random
import uuid
from dataclasses import dataclass
from typing import Literal

from app.models.flashcard import (
    FlashcardCard,
    FlashcardRoundResponse,
    FlashcardValidationResponse,
    FlashcardValidationResult,
)


Language = Literal["en", "th"]
Category = Literal["noun", "pronoun", "verb", "adverb", "adjective", "preposition", "determiner", "conjunction"]


@dataclass(frozen=True)
class WordBankEntry:
    id: str
    category: Category
    en: str
    th: str
    image_asset: str


WORD_BANK: tuple[WordBankEntry, ...] = (
    # Pronouns
    WordBankEntry("pronoun_i", "pronoun", "I", "ฉัน", "emoji:🙋"),
    WordBankEntry("pronoun_you", "pronoun", "you", "คุณ", "emoji:🫵"),
    WordBankEntry("pronoun_he", "pronoun", "he", "เขา", "emoji:🧑"),
    WordBankEntry("pronoun_she", "pronoun", "she", "เธอ", "emoji:👩"),
    WordBankEntry("pronoun_we", "pronoun", "we", "พวกเรา", "emoji:👥"),
    WordBankEntry("pronoun_they", "pronoun", "they", "พวกเขา", "emoji:👥"),
    WordBankEntry("pronoun_it", "pronoun", "it", "มัน", "emoji:🐾"),

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

    # Prepositions
    WordBankEntry("prep_in", "preposition", "in", "ใน", "emoji:📥"),
    WordBankEntry("prep_on", "preposition", "on", "บน", "emoji:📤"),
    WordBankEntry("prep_at", "preposition", "at", "ที่", "emoji:📍"),
    WordBankEntry("prep_with", "preposition", "with", "กับ", "emoji:🤝"),
    WordBankEntry("prep_under", "preposition", "under", "ใต้", "emoji:👇"),

    # Determiners
    WordBankEntry("det_a", "determiner", "a", "หนึ่ง", "emoji:1️⃣"),
    WordBankEntry("det_the", "determiner", "the", "นั้น", "emoji:👈"),

    # Conjunctions
    WordBankEntry("conj_and", "conjunction", "and", "และ", "emoji:➕"),

    # Adverbs
    WordBankEntry("adv_here", "adverb", "here", "ที่นี่", "emoji:📍"),
    WordBankEntry("adv_now", "adverb", "now", "ตอนนี้", "emoji:⏰"),
    WordBankEntry("adv_slowly", "adverb", "slowly", "ช้าๆ", "emoji:🐢"),
    WordBankEntry("adv_quickly", "adverb", "quickly", "เร็วๆ", "emoji:⚡"),

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


# --- Semantic groups for deterministic, sensible sentence generation ---------
# Only ids that exist in WORD_BANK above are referenced here.

# Who can start a sentence.
_SUBJECTS = [
    "pronoun_i", "pronoun_you", "pronoun_he", "pronoun_she",
    "pronoun_we", "pronoun_they",
    "noun_cat", "noun_dog", "noun_bird", "noun_cow", "noun_pig",
    "noun_horse", "noun_rabbit", "noun_chicken", "noun_elephant",
    "noun_mouse", "noun_goose", "noun_goldfish",
]

# Edible objects (fruits + vegetables).
_FOODS = [
    "noun_apple", "noun_banana", "noun_lime", "noun_mango", "noun_orange",
    "noun_pineapple", "noun_strawberry", "noun_watermelon",
    "noun_broccoli", "noun_carrot", "noun_corn", "noun_cucumber",
    "noun_mushroom", "noun_potato", "noun_pumpkin", "noun_tomato",
]

# Things that can be washed.
_WASHABLES = ["noun_glass", "noun_spoon", "noun_table", "noun_chair"]

# verb id -> the object group that keeps the sentence meaningful.
_VERB_OBJECTS: dict[str, list[str]] = {
    "verb_eat": _FOODS,
    "verb_read": ["noun_book"],
    "verb_wash": _WASHABLES,
}

# place id -> the preposition that reads naturally before it.
_PLACE_PREP: dict[str, str] = {
    "noun_home": "prep_at",
    "noun_school": "prep_at",
    "noun_shop": "prep_at",
    "noun_kitchen": "prep_in",
    "noun_garden": "prep_in",
    "noun_bathroom": "prep_in",
}


class FlashcardService:
    def __init__(self):
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
        """Deterministically assemble a simple, meaningful sentence from the
        word bank using semantic templates, so the ordered card ids always read
        sensibly (no LLM, no nonsense like "I eat apple a happy")."""
        for _ in range(8):
            ids = self._build_sentence_ids(word_count)
            if ids and self._target_ids_are_valid(ids, word_count):
                return ids
        return self._fallback_target_ids(word_count)

    def _build_sentence_ids(self, word_count: int) -> list[str] | None:
        subject = random.choice(_SUBJECTS)
        verb = random.choice(list(_VERB_OBJECTS.keys()))
        objects = _VERB_OBJECTS[verb]

        if word_count == 3:
            # Subject + Verb + Object
            return [subject, verb, random.choice(objects)]

        if word_count == 5:
            # Subject + Verb + Object + Preposition + Place
            place = random.choice(list(_PLACE_PREP.keys()))
            return [subject, verb, random.choice(objects), _PLACE_PREP[place], place]

        if word_count == 7:
            # Subject + Verb + Object + "and" + Object2 + Preposition + Place
            if len(objects) < 2:
                return None
            obj1, obj2 = random.sample(objects, 2)
            place = random.choice(list(_PLACE_PREP.keys()))
            return [subject, verb, obj1, "conj_and", obj2, _PLACE_PREP[place], place]

        return None

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
            3: ["pronoun_i", "verb_eat", "noun_apple"],
            5: ["pronoun_he", "verb_read", "noun_book", "prep_at", "noun_school"],
            7: [
                "pronoun_she",
                "verb_eat",
                "noun_banana",
                "conj_and",
                "noun_apple",
                "prep_at",
                "noun_home",
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
        results = []
        for i, card_id in enumerate(selected_ids):
            if i < len(target_ids) and target_ids[i] == card_id:
                results.append({"card_id": card_id, "status": "correct", "current_index": i, "target_index": i})
            elif card_id in target_ids:
                results.append({"card_id": card_id, "status": "move", "current_index": i, "target_index": target_ids.index(card_id)})
            else:
                results.append({"card_id": card_id, "status": "remove", "current_index": i})
        return results

    def _deterministic_validation(
        self,
        language: Language,
        target_ids: list[str],
        selected_ids: list[str],
    ) -> FlashcardValidationResponse:
        is_correct = target_ids == selected_ids

        results: list[FlashcardValidationResult] = []
        for i, card_id in enumerate(selected_ids):
            if i < len(target_ids) and target_ids[i] == card_id:
                results.append(
                    FlashcardValidationResult(
                        card_id=card_id,
                        status="correct",
                        current_index=i,
                        target_index=i,
                    )
                )
            elif card_id in target_ids:
                results.append(
                    FlashcardValidationResult(
                        card_id=card_id,
                        status="move",
                        current_index=i,
                        target_index=target_ids.index(card_id),
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
