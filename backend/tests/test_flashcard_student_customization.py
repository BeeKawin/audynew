import unittest

from app.services.flashcard_service import FlashcardService


class FlashcardStudentCustomizationTest(unittest.TestCase):
    def test_every_custom_category_appears_and_validates_at_each_supported_length(self):
        service = FlashcardService()
        words = {
            "noun": ("flower", "ดอกไม้"),
            "pronoun": ("we", "พวกเรา"),
            "verb": ("dance", "เต้น"),
            "adjective": ("bright", "สดใส"),
            "adverb": ("gently", "เบาๆ"),
        }
        for category, translations in words.items():
            for language, word in zip(("en", "th"), translations):
                for length in (3, 5, 7):
                    with self.subTest(category=category, language=language, length=length):
                        card_id = f"custom:{category}"
                        cards = [{"id": card_id, "word": word, "category": category}]
                        result = service.generate_round(language, length, cards, prefer_custom=True)
                        self.assertEqual(len(set(result.target_card_ids)), length)
                        custom_card = next(card for card in result.cards if card.id == card_id)
                        self.assertEqual(custom_card.display_text, word)
                        self.assertEqual(custom_card.category, category)
                        self.assertIn(word, result.scenario)
                        # Validate on a fresh server instance, as a retried HTTP request may.
                        validated = FlashcardService().validate(
                            result.round_id, language, result.target_card_ids, result.target_card_ids, cards
                        )
                        self.assertTrue(validated.is_correct)

    def test_custom_ids_cannot_replace_built_in_cards(self):
        cards = [{"id": "pronoun_i", "word": "bad replacement", "category": "noun"}]
        result = FlashcardService().generate_round("en", 3, cards, prefer_custom=True)
        self.assertEqual(len(result.cards), 3)
        self.assertNotIn("bad replacement", result.sentence_text)
