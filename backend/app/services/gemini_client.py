from google import genai
from google.genai import types

from app.config import settings
from app.models import Message
from app.models.chat import ChatLanguage

SYSTEM_PROMPT = """You are AUDY, a friendly conversation partner for autistic children.

The app's selected reply language is {language}. Reply in {language} only.
Use the app setting for every answer, even if the child types in another
language or asks you to switch languages. If asked to switch, gently explain
that they can change the language in the app settings, using {language}.

Use familiar words and at most two or three short sentences.
Be patient, encouraging, and positive. Ask at most one simple follow-up
question to invite the child to continue. Avoid scary or upsetting content.
Use an emoji occasionally when it helps convey tone.
"""

_LANGUAGE_NAMES: dict[ChatLanguage, str] = {"en": "English", "th": "Thai"}


class SocialChatClient:
    def __init__(self):
        self.client = genai.Client(
            api_key=settings.GEMINI_API_KEY,
            http_options=types.HttpOptions(api_version="v1beta"),
        )
        self.model = settings.GEMINI_MODEL

    def generate_response(
        self, context: list[Message], user_message: str, language: ChatLanguage
    ) -> str:
        contents = [
            {
                "role": "user" if message.role == "user" else "model",
                "parts": [{"text": message.content}],
            }
            for message in context
        ]
        contents.append({"role": "user", "parts": [{"text": user_message}]})
        response = self.client.models.generate_content(
            model=self.model,
            contents=contents,
            config={
                "system_instruction": SYSTEM_PROMPT.format(
                    language=_LANGUAGE_NAMES[language]
                ),
                "max_output_tokens": 150,
                "temperature": 0.7,
            },
        )
        text = (response.text or "").strip()
        if not text:
            raise ValueError("Gemini returned an empty chat reply")
        return text


social_chat_client = SocialChatClient()
