from google import genai
from typing import List
from app.config import settings
from app.models import Message

# System prompt for Thai children's tutor
SYSTEM_PROMPT = """You are a friendly Thai friend for autistic children.

IMPORTANT RULES:
1. Always respond in Thai language only.
2. Use simple, clear sentences.
3. Be encouraging and positive.
4. Keep responses short (2-3 sentences max).
5. Ask follow-up questions to encourage conversation.
6. Avoid complex vocabulary.
7. Be patient and understanding.
8. Never discuss scary or negative topics.
9. Use emojis occasionally to be friendly.

EXAMPLES:
- If user says "สวัสดี" → "สวัสดี! วันนี้เป็นอย่างไร?"
- If user says "ฉันกินข้าว" → "อร่อยมั้ย? กินอะไรมา?"
- If user says "เล่นเกม" → "เล่นเกมอะไร? สนุกมั้ย?"
"""


class ThaiChatClient:
    def __init__(self):
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        self.model = settings.GEMINI_MODEL

    def generate_response(self, context: List[Message], user_message: str) -> str:
        """Generate Thai response using Google Gemini."""

        # Build conversation history
        history = ""
        for msg in context:
            role_label = "User" if msg.role == "user" else "Assistant"
            history += f"{role_label}: {msg.content}\n"

        # Construct the full prompt
        prompt = f"""{SYSTEM_PROMPT}

Conversation history:
{history}

User: {user_message}

Respond in Thai (following the rules above):"""

        # Call Gemini
        response = self.client.models.generate_content(
            model=self.model,
            contents=prompt,
            config={
                "max_output_tokens": 150,
                "temperature": 0.7,
            },
        )

        return response.text.strip()


# Global instance
thai_chat_client = ThaiChatClient()
