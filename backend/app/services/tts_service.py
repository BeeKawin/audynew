import base64
import re
import wave
from io import BytesIO

import httpx

from app.config import settings
from app.models.chat import ChatLanguage


class TTSService:
    """Generate WAV speech for AUDY in the selected app language."""

    async def generate_speech(self, text: str, language: ChatLanguage = "th") -> bytes:
        if not settings.GEMINI_API_KEY:
            raise ValueError("GEMINI_API_KEY not configured")
        if not text.strip():
            raise ValueError("Text cannot be empty")

        model = settings.GEMINI_TTS_MODEL
        language_name = "English" if language == "en" else "Thai"
        style = f"Speak clearly and warmly in {language_name}, at a calm pace."
        if model.startswith("gemini-3.8-"):
            part = {"text": text, "speech_metadata": {"style": style}}
        else:
            part = {"text": f"{style}\n\n## Transcript:\n{text}"}

        request_body = {
            "contents": [{"role": "user", "parts": [part]}],
            "generationConfig": {
                "responseModalities": ["AUDIO"],
                "speechConfig": {
                    "voiceConfig": {
                        "prebuiltVoiceConfig": {"voiceName": "Algenib"},
                    },
                },
            },
        }
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent",
                headers={"x-goog-api-key": settings.GEMINI_API_KEY},
                json=request_body,
            )
        response.raise_for_status()

        for candidate in response.json().get("candidates", []):
            for part in candidate.get("content", {}).get("parts", []):
                audio = part.get("inlineData", {})
                if audio.get("data"):
                    return self._wav_audio(
                        base64.b64decode(audio["data"]), audio.get("mimeType", "")
                    )
        raise ValueError("Gemini returned no audio")

    @staticmethod
    def _wav_audio(data: bytes, mime_type: str) -> bytes:
        # Gemini 3.8 returns WAV. Legacy models return raw 16-bit PCM.
        if data.startswith(b"RIFF") and data[8:12] == b"WAVE":
            return data
        if not mime_type.lower().startswith("audio/l16"):
            raise ValueError("Unsupported Gemini audio format")
        rate = re.search(r"(?:^|;)\s*rate=(\d+)", mime_type, re.IGNORECASE)
        buffer = BytesIO()
        with wave.open(buffer, "wb") as speech:
            speech.setnchannels(1)
            speech.setsampwidth(2)
            speech.setframerate(int(rate[1]) if rate else 24000)
            speech.writeframes(data)
        return buffer.getvalue()


tts_service = TTSService()
