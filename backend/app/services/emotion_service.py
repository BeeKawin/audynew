"""Server-side facial emotion classification using Hugging Face ViT."""

import io
import logging
import os
from typing import Dict

import numpy as np
from PIL import Image

logger = logging.getLogger(__name__)

# Try to import transformers, provide fallback if not available
try:
    from transformers import ViTForImageClassification, ViTImageProcessor
    import torch

    TRANSFORMERS_AVAILABLE = True
except ImportError:
    TRANSFORMERS_AVAILABLE = False
    logger.warning(
        "transformers/torch not installed. Emotion classification will not work."
    )

# Map model labels to app-friendly emotion names (7 emotions)
MODEL_TO_APP = {
    "anger": "Angry",
    "angry": "Angry",
    "disgust": "Disgust",
    "fear": "Scared",
    "happy": "Happy",
    "neutral": "Calm",
    "sad": "Sad",
    "surprise": "Surprised",
}

MIN_CONFIDENCE = 0.4


class EmotionService:
    """HuggingFace ViT-based emotion classification service."""

    def __init__(
        self,
        model_name: str | None = None,
    ):
        self.model_name = model_name or os.getenv(
            "EMOTION_MODEL_NAME",
            "mo-thecreator/vit-Facial-Expression-Recognition",
        )
        self.model = None
        self.processor = None
        self.initialized = False
        self._load_error = None

        if TRANSFORMERS_AVAILABLE:
            self._load_model()
        else:
            self._load_error = "Emotion model dependencies are not installed."

    def _load_model(self):
        """Load the configured Hugging Face ViT model."""
        try:
            logger.info("Loading emotion model: %s", self.model_name)
            self.processor = ViTImageProcessor.from_pretrained(self.model_name)
            self.model = ViTForImageClassification.from_pretrained(self.model_name)
            self.model.eval()
            self.initialized = True
            self._load_error = None
            logger.info("Emotion model loaded successfully")
        except Exception:
            self.model = None
            self.processor = None
            self.initialized = False
            self._load_error = "The emotion model could not be loaded."
            logger.exception("Failed to load emotion model")

    def is_ready(self) -> bool:
        """Check if model is loaded and ready."""
        return self.initialized and self.model is not None and self.processor is not None

    def _model_label(self, index: int) -> str:
        """Read a label from the model configuration without assuming class order."""
        id_to_label = getattr(self.model.config, "id2label", {})
        label = id_to_label.get(index, id_to_label.get(str(index), f"class_{index}"))
        return str(label).lower()

    def preprocess(self, image_bytes: bytes):
        """
        Preprocess image for ViT model.
        Uses ViTImageProcessor which handles resize to 224x224 and normalization.
        """
        image = Image.open(io.BytesIO(image_bytes))

        # Convert to RGB if needed
        if image.mode != "RGB":
            image = image.convert("RGB")

        # Use ViTImageProcessor for consistent preprocessing
        inputs = self.processor(images=image, return_tensors="pt")
        return inputs

    def softmax(self, x: np.ndarray) -> np.ndarray:
        """Apply softmax activation."""
        exp_x = np.exp(x - np.max(x))
        return exp_x / exp_x.sum()

    def classify(self, image_bytes: bytes) -> Dict[str, object]:
        """
        Classify emotion from image.
        """
        if not self.is_ready():
            raise RuntimeError(
                f"Emotion model not loaded. Error: {self._load_error or 'Unknown'}"
            )

        # Preprocess
        inputs = self.preprocess(image_bytes)

        # Run inference (no gradient computation)
        with torch.no_grad():
            outputs = self.model(**inputs)

        # Get logits and apply softmax
        logits = outputs.logits[0].cpu().numpy()
        probabilities = self.softmax(logits)

        # Get prediction
        max_idx = int(np.argmax(probabilities))
        max_conf = float(probabilities[max_idx])

        model_label = self._model_label(max_idx)
        app_emotion = MODEL_TO_APP.get(model_label, "Calm")

        # Build all probabilities dict
        all_probs = {
            self._model_label(i): float(probabilities[i])
            for i in range(len(probabilities))
        }

        return {
            "detected_emotion": app_emotion,
            "confidence": max_conf,
            "is_confident": max_conf >= MIN_CONFIDENCE,
            "model_label": model_label,
            "all_probabilities": all_probs,
        }


# Global instance (lazy loaded)
_emotion_service = None


def get_emotion_service() -> EmotionService:
    """Get or create global emotion service instance."""
    global _emotion_service
    if _emotion_service is None:
        _emotion_service = EmotionService()
    return _emotion_service
