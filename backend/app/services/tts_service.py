import base64
import json
import struct
from io import BytesIO
from typing import Optional

import httpx
from app.config import settings


class TTSService:
    """Text-to-Speech service using Google Gemini Flash TTS Preview API."""

    # API endpoint for Gemini TTS
    _API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-tts-preview:generateContent"

    # Character context for the voice (same as Flutter app)
    _CHARACTER_CONTEXT = """## Sample Context:
light-hearted and kind, fat appearance, bear-like, little deep voice, comfortable, suitable for talking with young children, can speak Thai, male voice, fat voice"""

    async def generate_speech(self, text: str) -> bytes:
        """
        Generate speech from text using Gemini TTS API.
        
        Args:
            text: The text to convert to speech (Thai)
            
        Returns:
            WAV audio bytes
            
        Raises:
            Exception: If API call fails or no audio is generated
        """
        if not settings.GEMINI_API_KEY:
            raise Exception("GEMINI_API_KEY not configured")

        if not text:
            raise Exception("Text cannot be empty")

        # Build request payload
        request_body = {
            "contents": [
                {
                    "role": "user",
                    "parts": [
                        {
                            "text": f"""{self._CHARACTER_CONTEXT}

## Transcript:
{text}"""
                        }
                    ]
                }
            ],
            "generationConfig": {
                "temperature": 1.0,
                "responseModalities": ["AUDIO"],
                "speechConfig": {
                    "voiceConfig": {
                        "prebuiltVoiceConfig": {
                            "voiceName": "Algenib"
                        }
                    }
                }
            }
        }

        # Make API call with timeout
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                f"{self._API_URL}?key={settings.GEMINI_API_KEY}",
                headers={"Content-Type": "application/json"},
                json=request_body
            )

        if response.status_code != 200:
            raise Exception(f"Gemini API error: {response.status_code} - {response.text}")

        # Parse response
        response_data = response.json()
        
        # Extract audio data
        candidates = response_data.get("candidates", [])
        if not candidates:
            raise Exception("No audio generated")

        content = candidates[0].get("content", {})
        parts = content.get("parts", [])
        
        if not parts:
            raise Exception("No audio parts in response")

        inline_data = parts[0].get("inlineData", {})
        mime_type = inline_data.get("mimeType", "")
        base64_data = inline_data.get("data", "")

        if not base64_data:
            raise Exception("No audio data received")

        # Decode base64 audio
        audio_bytes = base64.b64decode(base64_data)
        
        # Convert to WAV format
        wav_bytes = self._convert_to_wav(audio_bytes, mime_type)
        
        return wav_bytes

    def _convert_to_wav(self, audio_data: bytes, mime_type: str) -> bytes:
        """
        Convert raw PCM audio to WAV format.
        
        Args:
            audio_data: Raw PCM bytes
            mime_type: MIME type like "audio/L16;rate=24000"
            
        Returns:
            WAV formatted bytes
        """
        # Parse mime type for parameters
        params = self._parse_audio_mime_type(mime_type)
        bits_per_sample = params.get("bits_per_sample", 16)
        sample_rate = params.get("rate", 24000)
        num_channels = 1

        data_size = len(audio_data)
        bytes_per_sample = bits_per_sample // 8
        block_align = num_channels * bytes_per_sample
        byte_rate = sample_rate * block_align
        chunk_size = 36 + data_size

        # Build WAV header
        buffer = BytesIO()
        
        # "RIFF" chunk descriptor
        buffer.write(b"RIFF")
        buffer.write(struct.pack("<I", chunk_size))
        buffer.write(b"WAVE")
        
        # "fmt " sub-chunk
        buffer.write(b"fmt ")
        buffer.write(struct.pack("<I", 16))  # Subchunk1Size (16 for PCM)
        buffer.write(struct.pack("<H", 1))   # AudioFormat (1 for PCM)
        buffer.write(struct.pack("<H", num_channels))
        buffer.write(struct.pack("<I", sample_rate))
        buffer.write(struct.pack("<I", byte_rate))
        buffer.write(struct.pack("<H", block_align))
        buffer.write(struct.pack("<H", bits_per_sample))
        
        # "data" sub-chunk
        buffer.write(b"data")
        buffer.write(struct.pack("<I", data_size))
        
        # Write audio data
        buffer.write(audio_data)
        
        return buffer.getvalue()

    def _parse_audio_mime_type(self, mime_type: str) -> dict:
        """
        Parse audio MIME type to extract parameters.
        
        Args:
            mime_type: MIME type string like "audio/L16;rate=24000"
            
        Returns:
            Dictionary with bits_per_sample and rate
        """
        bits_per_sample = 16
        rate = 24000

        parts = mime_type.split(";")
        for param in parts:
            trimmed = param.strip()
            if trimmed.lower().startswith("rate="):
                try:
                    rate = int(trimmed.split("=")[1])
                except (ValueError, IndexError):
                    pass
            elif trimmed.lower().startswith("audio/l"):
                try:
                    bits_per_sample = int(trimmed[7:])
                except ValueError:
                    pass

        return {"bits_per_sample": bits_per_sample, "rate": rate}


# Global instance
tts_service = TTSService()
