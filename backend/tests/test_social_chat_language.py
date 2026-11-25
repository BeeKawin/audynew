import base64
import unittest
from types import SimpleNamespace
from unittest.mock import AsyncMock, MagicMock, patch

import httpx
from fastapi.testclient import TestClient

from app.config import settings
from app.main import app
from app.services.gemini_client import social_chat_client
from app.services.tts_service import TTSService


class SocialChatLanguageTest(unittest.TestCase):
    def test_app_language_controls_prompt_and_history_across_switches(self):
        with TestClient(app) as api, patch.object(
            social_chat_client, "client"
        ) as gemini:
            generate = gemini.models.generate_content
            generate.return_value = SimpleNamespace(text="A simple reply.")
            english = api.post(
                "/api/social-chat", json={"message": "สวัสดี", "language": "en"}
            )
            self.assertEqual(english.status_code, 200)
            english_session = english.json()["session_id"]
            request = generate.call_args.kwargs
            self.assertIn("Reply in English only", request["config"]["system_instruction"])
            self.assertEqual(request["contents"][0]["parts"][0]["text"], "สวัสดี")

            thai = api.post(
                "/api/social-chat",
                json={"message": "Hello", "language": "th", "session_id": english_session},
            )
            self.assertEqual(thai.status_code, 200)
            self.assertNotEqual(thai.json()["session_id"], english_session)
            request = generate.call_args.kwargs
            self.assertIn("Reply in Thai only", request["config"]["system_instruction"])
            self.assertEqual(len(request["contents"]), 1)

            back = api.post(
                "/api/social-chat",
                json={"message": "My second turn", "language": "en", "session_id": english_session},
            )
            self.assertEqual(back.json()["session_id"], english_session)
            self.assertEqual(
                [turn["role"] for turn in generate.call_args.kwargs["contents"]],
                ["user", "model", "user"],
            )

    def test_legacy_chat_defaults_to_thai_and_invalid_languages_fail(self):
        with TestClient(app) as api, patch.object(
            social_chat_client, "client"
        ) as gemini:
            gemini.models.generate_content.return_value = SimpleNamespace(text="สวัสดี")
            self.assertEqual(api.post("/api/thai-chat", json={"message": "สวัสดี"}).status_code, 200)
            prompt = gemini.models.generate_content.call_args.kwargs["config"]["system_instruction"]
            self.assertIn("Reply in Thai only", prompt)
            self.assertEqual(
                api.post("/api/social-chat", json={"message": "Hi", "language": "fr"}).status_code,
                422,
            )

    def test_tts_passes_the_language_and_keeps_the_wav_from_gemini(self):
        wav = TTSService._wav_audio(b"\0\0\1\0", "audio/L16;rate=24000")
        upstream = httpx.Response(
            200,
            request=httpx.Request("POST", "https://example.test"),
            json={"candidates": [{"content": {"parts": [{"inlineData": {
                "mimeType": "audio/wav", "data": base64.b64encode(wav).decode(),
            }}]}}]},
        )
        transport = MagicMock()
        transport.__aenter__.return_value.post = AsyncMock(return_value=upstream)
        with TestClient(app) as api, patch.object(
            settings, "GEMINI_API_KEY", "test-key"
        ), patch.object(settings, "GEMINI_TTS_MODEL", "gemini-3.8-flash-tts"), patch(
            "app.services.tts_service.httpx.AsyncClient", return_value=transport
        ):
            post = transport.__aenter__.return_value.post
            for body, text, language in [
                ({"text": "Hello", "language": "en"}, "Hello", "English"),
                ({"text": "สวัสดี"}, "สวัสดี", "Thai"),
            ]:
                with self.subTest(language=language):
                    response = api.post("/api/tts", json=body)
                    self.assertEqual(response.status_code, 200)
                    self.assertEqual(response.content, wav)
                    part = post.call_args.kwargs["json"]["contents"][0]["parts"][0]
                    self.assertEqual(part["text"], text)
                    self.assertIn(language, part["speech_metadata"]["style"])
