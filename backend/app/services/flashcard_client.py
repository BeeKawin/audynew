import json
import re
from typing import List, Optional

from google import genai

from app.config import settings

# Constrained vocabulary with emoji glyphs. Generation is steered to pick words
# from here so the Flutter client can resolve the same glyph it renders today
# (mirrors FlashWordPool in flashcard_levels.dart). Unknown words simply render
# without a glyph on the client.
VOCAB = {
    "pronoun": {"I": "🙋", "You": "👉", "He": "👦", "She": "👧", "It": "🐻", "We": "👨‍👩‍👧", "They": "👬"},
    "noun": {"cat": "🐱", "dog": "🐶", "ball": "⚽", "apple": "🍎", "book": "📖", "chair": "🪑", "bird": "🐦", "fish": "🐟"},
    "verb": {"sits": "💺", "sit": "💺", "runs": "🏃", "run": "🏃", "eats": "🍽️", "eat": "🍽️", "plays": "🎮", "play": "🎮", "sleeps": "😴", "sleep": "😴", "jumps": "🤸", "jump": "🤸"},
    "adjective": {"big": "🐘", "small": "🐜", "happy": "😄", "red": "🔴", "blue": "🔵", "fast": "⚡"},
    "adverb": {"quietly": "🤫", "quickly": "💨", "slowly": "🐌", "happily": "😊"},
    "preposition": {"on": "⬆️", "in": "📦", "under": "⬇️", "with": "🤝"},
}

SYSTEM_RULES = """You build short English sentences for autistic children learning grammar.
Keep it simple, positive, and age-appropriate. Use only common, concrete words."""


def _glyph_for(word: str, pos: str) -> Optional[str]:
    pool = VOCAB.get(pos, {})
    return pool.get(word) or pool.get(word.lower()) or pool.get(word.capitalize())


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

Return STRICT JSON only:
{{
  "sentence": [{{"word": "It", "pos": "pronoun"}}, {{"word": "sits", "pos": "verb"}}],
  "distractors": [{{"word": "sit", "pos": "verb"}}]
}}"""
        data = self._generate_json(prompt)

        def _normalize(items):
            out = []
            for it in items or []:
                w, p = str(it.get("word", "")).strip(), str(it.get("pos", "")).strip().lower()
                if not w or not p:
                    continue
                out.append({"word": w, "pos": p, "glyph": it.get("glyph") or _glyph_for(w, p)})
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

For each MISPLACED or wrong word, return its index and a short reason.
Example: for "Plays Quietly It" you flag index 0 (Plays) and the ordering so the
child sees "Quietly" and "It" are out of place — list every wrong index.

Return STRICT JSON only:
{{
  "valid": false,
  "errors": [{{"index": 1, "reason": "adverb is misplaced"}}],
  "feedback": "Almost! Try moving the words around."
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
        return {
            "valid": bool(data.get("valid", False)),
            "errors": errors,
            "feedback": str(data.get("feedback", "")),
        }


# Global instance
flashcard_client = FlashcardClient()
