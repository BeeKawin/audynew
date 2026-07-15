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

    # Relatives (nouns)
    WordBankEntry("noun_father", "noun", "father", "พ่อ", "emoji:👨"),
    WordBankEntry("noun_mother", "noun", "mother", "แม่", "emoji:👩"),
    WordBankEntry("noun_brother", "noun", "brother", "พี่ชาย", "emoji:👦"),
    WordBankEntry("noun_sister", "noun", "sister", "น้องสาว", "emoji:👧"),
    WordBankEntry("noun_teacher", "noun", "teacher", "ครู", "emoji:👩‍🏫"),

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
    "noun_father", "noun_mother", "noun_brother", "noun_sister",
    "noun_teacher",
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

    def _create_context(self, custom_cards: list[dict] = None):
        local_entry_by_id = dict(ENTRY_BY_ID)
        local_subjects = list(_SUBJECTS)
        local_foods = list(_FOODS)
        local_washables = list(_WASHABLES)
        local_verb_objects = {k: list(v) for k, v in _VERB_OBJECTS.items()}
        local_place_prep = dict(_PLACE_PREP)

        if custom_cards:
            for card in custom_cards:
                c_id = card.get("id") or str(uuid.uuid4())
                category = card.get("category")
                word = card.get("word") or ""
                image_url = card.get("image_url") or "emoji:🃏"

                valid_categories = ["noun", "pronoun", "verb", "adverb", "adjective", "preposition", "determiner", "conjunction"]
                if category not in valid_categories:
                    category = "noun"

                entry = WordBankEntry(
                    id=c_id,
                    category=category,
                    en=word,
                    th=word,
                    image_asset=image_url,
                )
                local_entry_by_id[c_id] = entry

                if category == "pronoun":
                    local_subjects.append(c_id)
                elif category == "noun":
                    local_foods.append(c_id)
                    local_washables.append(c_id)
                elif category == "verb":
                    local_verb_objects[c_id] = local_foods

        return {
            "entry_by_id": local_entry_by_id,
            "subjects": local_subjects,
            "verb_objects": local_verb_objects,
            "place_prep": local_place_prep,
        }

    def generate_round(
        self,
        language: Language,
        word_count: int,
        custom_cards: list[dict] = None,
    ) -> FlashcardRoundResponse:
        ctx = self._create_context(custom_cards)
        target_ids = self._generate_target_ids(language, word_count, ctx)
        round_id = str(uuid.uuid4())
        self._round_targets[round_id] = target_ids
        return self._build_round_response(round_id, language, word_count, target_ids, ctx)

    def validate(
        self,
        round_id: str,
        language: Language,
        target_card_ids: list[str],
        selected_card_ids: list[str],
        custom_cards: list[dict] = None,
    ) -> FlashcardValidationResponse:
        ctx = self._create_context(custom_cards)
        entry_by_id = ctx["entry_by_id"]

        target_ids = self._round_targets.get(round_id) or target_card_ids
        target_ids = [card_id for card_id in target_ids if card_id in entry_by_id]
        selected_ids = [card_id for card_id in selected_card_ids if card_id in entry_by_id]

        if not target_ids:
            return self._deterministic_validation(language, [], selected_ids, ctx)

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

        return self._deterministic_validation(language, target_ids, selected_ids, ctx)

    def _generate_target_ids(self, language: Language, word_count: int, ctx: dict) -> list[str]:
        for _ in range(8):
            ids = self._build_sentence_ids(word_count, ctx)
            if ids and self._target_ids_are_valid(ids, word_count, ctx):
                return ids
        return self._fallback_target_ids(word_count)

    def _build_sentence_ids(self, word_count: int, ctx: dict) -> list[str] | None:
        subjects = ctx["subjects"]
        verb_objects = ctx["verb_objects"]
        place_prep = ctx["place_prep"]

        if not subjects or not verb_objects:
            return None

        subject = random.choice(subjects)
        verb = random.choice(list(verb_objects.keys()))
        objects = verb_objects[verb]

        if not objects:
            return None

        if word_count == 3:
            return [subject, verb, random.choice(objects)]

        if word_count == 5:
            if not place_prep:
                return None
            place = random.choice(list(place_prep.keys()))
            return [subject, verb, random.choice(objects), place_prep[place], place]

        if word_count == 7:
            if len(objects) < 2 or not place_prep:
                return None
            obj1, obj2 = random.sample(objects, 2)
            place = random.choice(list(place_prep.keys()))
            return [subject, verb, obj1, "conj_and", obj2, place_prep[place], place]

        return None

    def _validate_with_llm(
        self,
        language: Language,
        target_ids: list[str],
        selected_ids: list[str],
    ) -> list[dict]:
        return self._deterministic_set_results(target_ids, selected_ids)

    def _target_ids_are_valid(self, ids: list[str], word_count: int, ctx: dict) -> bool:
        entry_by_id = ctx["entry_by_id"]
        return (
            isinstance(ids, list)
            and len(ids) == word_count
            and len(set(ids)) == len(ids)
            and all(card_id in entry_by_id for card_id in ids)
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

    def _generate_scenario(self, target_ids: list[str], language: Language) -> str:
        entries = [ENTRY_BY_ID[tid] for tid in target_ids if tid in ENTRY_BY_ID]
        if not entries:
            return ""

        subject_entry = None
        verb_entry = None
        object_entries = []
        prep_entry = None
        place_entry = None
        
        for entry in entries:
            if entry.category == "pronoun" or (entry.category == "noun" and entry.id in _SUBJECTS):
                if not subject_entry:
                    subject_entry = entry
            elif entry.category == "verb":
                verb_entry = entry
            elif entry.category == "noun" and entry.id not in _SUBJECTS and entry.id not in _PLACE_PREP:
                object_entries.append(entry)
            elif entry.category == "preposition":
                prep_entry = entry
            elif entry.category == "noun" and entry.id in _PLACE_PREP:
                place_entry = entry

        if not subject_entry or not verb_entry:
            return " ".join(e.th if language == "th" else e.en for e in entries)

        if language == "en":
            subj_text = subject_entry.en
            if subj_text.lower() == "i":
                be_verb = "am"
            elif subj_text.lower() in ["you", "we", "they"]:
                be_verb = "are"
            else:
                be_verb = "is"

            verb_ing = {
                "eat": "eating",
                "drink": "drinking",
                "sleep": "sleeping",
                "walk": "walking",
                "run": "running",
                "play": "playing",
                "read": "reading",
                "write": "writing",
                "wash": "washing",
                "open": "opening",
                "close": "closing",
            }.get(verb_entry.en.lower(), verb_entry.en + "ing")

            def format_obj(obj_name: str) -> str:
                name = obj_name.lower()
                if name in ["apple", "orange", "elephant"]:
                    return f"an {obj_name}"
                elif name in ["banana", "lime", "mango", "pineapple", "strawberry", "watermelon", 
                              "broccoli", "carrot", "corn", "cucumber", "mushroom", "potato", 
                              "pumpkin", "tomato", "book", "pencil", "glass", "spoon", "table", "chair"]:
                    return f"a {obj_name}"
                return obj_name

            obj_text = ""
            if len(object_entries) == 1:
                obj_text = " " + format_obj(object_entries[0].en)
            elif len(object_entries) == 2:
                obj_text = f" {format_obj(object_entries[0].en)} and {format_obj(object_entries[1].en)}"

            place_text = ""
            if prep_entry and place_entry:
                place_text = f" {prep_entry.en} the {place_entry.en}"
            elif place_entry:
                place_text = f" at the {place_entry.en}"

            return f"Who is {verb_ing}{obj_text}{place_text}?"

        else:
            subj_text = subject_entry.th
            
            verb_text = {
                "กิน": "กำลังกิน",
                "ดื่ม": "กำลังดื่ม",
                "นอน": "กำลังนอน",
                "เดิน": "กำลังเดิน",
                "วิ่ง": "กำลังวิ่ง",
                "เล่น": "กำลังเล่น",
                "อ่าน": "กำลังอ่าน",
                "เขียน": "กำลังเขียน",
                "ล้าง": "กำลังล้าง",
                "เปิด": "กำลังเปิด",
                "ปิด": "กำลังปิด",
            }.get(verb_entry.th, f"กำลัง{verb_entry.th}")

            obj_text = ""
            if len(object_entries) == 1:
                obj_text = object_entries[0].th
            elif len(object_entries) == 2:
                obj_text = f"{object_entries[0].th}และ{object_entries[1].th}"

            place_text = ""
            if prep_entry and place_entry:
                place_text = f"{prep_entry.th}{place_entry.th}"
            elif place_entry:
                place_text = f"ที่{place_entry.th}"

            return f"ใคร{verb_text}{obj_text}{place_text}?"

    def _build_round_response(
        self,
        round_id: str,
        language: Language,
        word_count: int,
        target_ids: list[str],
        ctx: dict,
    ) -> FlashcardRoundResponse:
        entry_by_id = ctx["entry_by_id"]
        cards = [self._card_for_entry(entry_by_id[card_id], language) for card_id in target_ids]
        scenario = self._generate_scenario(target_ids, language)
        return FlashcardRoundResponse(
            round_id=round_id,
            language=language,
            word_count=word_count,
            sentence_text=" ".join(card.display_text for card in cards),
            cards=cards,
            target_card_ids=target_ids,
            scenario=scenario,
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

    def _words_for_ids(self, ids: list[str], language: Language, ctx: dict) -> list[str]:
        entry_by_id = ctx["entry_by_id"]
        return [
            entry_by_id[card_id].th if language == "th" else entry_by_id[card_id].en
            for card_id in ids
            if card_id in entry_by_id
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
        ctx: dict,
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
