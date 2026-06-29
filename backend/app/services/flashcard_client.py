import json
import re
from typing import List, Optional

from google import genai

from app.config import settings

# Constrained vocabulary: english word -> (emoji glyph, Thai display text).
# Generation is steered to pick words from here so the Flutter client can resolve
# the same glyph it renders today (mirrors FlashWordPool in flashcard_levels.dart)
# and so Thai mode shows Thai card text. Unknown words render glyph-less / English.
VOCAB = {
    "pronoun": {
        "I": ("🙋", "ฉัน"), "You": ("👉", "คุณ"), "He": ("👦", "เขา"),
        "She": ("👧", "เธอ"), "It": ("🐻", "มัน"), "We": ("👨‍👩‍👧", "เรา"),
        "They": ("👬", "พวกเขา"),
    },
    "noun": {
        "cat": ("🐱", "แมว"), "dog": ("🐶", "หมา"), "ball": ("⚽", "ลูกบอล"),
        "apple": ("🍎", "แอปเปิล"), "book": ("📖", "หนังสือ"),
        "chair": ("🪑", "เก้าอี้"), "bird": ("🐦", "นก"), "fish": ("🐟", "ปลา"),
    },
    "verb": {
        "sits": ("💺", "นั่ง"), "sit": ("💺", "นั่ง"), "runs": ("🏃", "วิ่ง"),
        "run": ("🏃", "วิ่ง"), "eats": ("🍽️", "กิน"), "eat": ("🍽️", "กิน"),
        "plays": ("🎮", "เล่น"), "play": ("🎮", "เล่น"), "sleeps": ("😴", "นอน"),
        "sleep": ("😴", "นอน"), "jumps": ("🤸", "กระโดด"), "jump": ("🤸", "กระโดด"),
    },
    "adjective": {
        "big": ("🐘", "ใหญ่"), "small": ("🐜", "เล็ก"), "happy": ("😄", "มีความสุข"),
        "red": ("🔴", "สีแดง"), "blue": ("🔵", "สีน้ำเงิน"), "fast": ("⚡", "เร็ว"),
    },
    "adverb": {
        "quietly": ("🤫", "อย่างเงียบ ๆ"), "quickly": ("💨", "อย่างรวดเร็ว"),
        "slowly": ("🐌", "อย่างช้า ๆ"), "happily": ("😊", "อย่างมีความสุข"),
    },
    "preposition": {
        "on": ("⬆️", "บน"), "in": ("📦", "ใน"), "under": ("⬇️", "ใต้"),
        "with": ("🤝", "กับ"),
    },
}

SYSTEM_RULES = """You build short English sentences for autistic children learning grammar.
Keep it simple, positive, and age-appropriate. Use only common, concrete words."""


def _lookup(word: str, pos: str):
    pool = VOCAB.get(pos, {})
    return (
        pool.get(word)
        or pool.get(word.lower())
        or pool.get(word.capitalize())
    )


def _glyph_for(word: str, pos: str) -> Optional[str]:
    hit = _lookup(word, pos)
    return hit[0] if hit else None


def _thai_for(word: str, pos: str) -> Optional[str]:
    hit = _lookup(word, pos)
    return hit[1] if hit else None


def _extract_json(text: str) -> dict:
    """Parse model output as JSON, tolerating ```json fences / stray prose."""
    text = text.strip()
    fence = re.search(r"```(?:json)?\s*(\{.*\})\s*```", text, re.DOTALL)
    if fence:
        text = fence.group(1)
    else:
        brace = re.search(r"\{.*\}", text, re.DOTALL)
        if brace:
            text = brace.group(0)
    return json.loads(text)


class FlashcardClient:
    def __init__(self):
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        self.model = settings.FLASHCARD_MODEL

    def _generate_json(self, prompt: str, max_tokens: int = 400) -> dict:
        response = self.client.models.generate_content(
            model=self.model,
            contents=prompt,
            config={
                "max_output_tokens": max_tokens,
                "temperature": 0.7,
                "response_mime_type": "application/json",
            },
        )
        return _extract_json(response.text)

    def generate_round(self, difficulty: str, language: str) -> dict:
        """Generate a target sentence + structure + distractor cards."""
        vocab_hint = json.dumps(
            {pos: list(words.keys()) for pos, words in VOCAB.items()},
            ensure_ascii=False,
        )
        prompt = f"""{SYSTEM_RULES}

Difficulty: {difficulty}
Prefer words from this vocabulary (pos -> allowed words):
{vocab_hint}

Build ONE grammatical English sentence. easy = Pronoun + Verb (3 words max),
medium = add an object or adverb, hard = add adjective/preposition.
Subject-verb agreement must be correct (e.g. "He sits", not "He sit").

Also return 2-3 DISTRACTOR words (wrong-fit cards, e.g. a wrong-agreement verb).

Keep "word" in English. Always include "word_th" with the Thai translation of
that word (so the card can be shown in Thai).

Return STRICT JSON only:
{{
  "sentence": [
    {{"word": "It", "pos": "pronoun", "word_th": "มัน"}},
    {{"word": "sits", "pos": "verb", "word_th": "นั่ง"}}
  ],
  "distractors": [{{"word": "sit", "pos": "verb", "word_th": "นั่ง"}}]
}}"""
        data = self._generate_json(prompt)

        def _normalize(items):
            out = []
            for it in items or []:
                w, p = str(it.get("word", "")).strip(), str(it.get("pos", "")).strip().lower()
                if not w or not p:
                    continue
                out.append({
                    "word": w,
                    "pos": p,
                    "glyph": it.get("glyph") or _glyph_for(w, p),
                    "word_th": it.get("word_th") or _thai_for(w, p),
                })
            return out

        sentence = _normalize(data.get("sentence"))
        distractors = _normalize(data.get("distractors"))
        structure = [w["pos"] for w in sentence]
        return {"sentence": sentence, "structure": structure, "distractors": distractors}

    def validate(
        self,
        words: List[str],
        pos_tags: Optional[List[str]],
        target_context: Optional[str],
        language: str,
    ) -> dict:
        """Validate a user sentence with meaning-equivalence + per-word flags."""
        numbered = "\n".join(f"{i}: {w}" for i, w in enumerate(words))
        ctx = f"\nTarget/instruction: {target_context}" if target_context else ""
        tags = f"\nPOS tags: {pos_tags}" if pos_tags else ""
        prompt = f"""{SYSTEM_RULES}

A child arranged these word cards left to right (index: word):
{numbered}{tags}{ctx}

Decide if the arrangement is a GRAMMATICAL English sentence. Accept any
meaning-equivalent correct ordering or synonym — do NOT require one exact answer.
Enforce subject-verb agreement.

If it is WRONG, identify the ONE card that is most out of place — the single card
the child should move/swap to fix the sentence — and return it in "swap_index".
Flag ONLY the genuinely wrong card(s) in "errors"; do not flag correct cards.
Example: for "Plays Quietly It" the verb "Plays" is misplaced, so swap_index = 0.

Return STRICT JSON only:
{{
  "valid": false,
  "errors": [{{"index": 0, "reason": "verb should not be first"}}],
  "swap_index": 0,
  "feedback": "Almost! Move this card to fix it."
}}"""
        data = self._generate_json(prompt, max_tokens=300)
        errors = []
        for e in data.get("errors", []) or []:
            try:
                idx = int(e.get("index"))
            except (TypeError, ValueError):
                continue
            if 0 <= idx < len(words):
                errors.append({"index": idx, "reason": str(e.get("reason", ""))})

        swap_index = data.get("swap_index")
        try:
            swap_index = int(swap_index)
            if not (0 <= swap_index < len(words)):
                swap_index = None
        except (TypeError, ValueError):
            swap_index = None
        # Ensure the swap target is always among the flagged (red) cards.
        if swap_index is not None and not any(e["index"] == swap_index for e in errors):
            errors.append({"index": swap_index, "reason": "move this card"})

        return {
            "valid": bool(data.get("valid", False)),
            "errors": errors,
            "swap_index": swap_index,
            "feedback": str(data.get("feedback", "")),
        }


# Global instance
flashcard_client = FlashcardClient()
