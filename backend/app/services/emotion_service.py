"""
Emotion Classification Service using HuggingFace Transformers.
Loads the ViT model from mo-thecreator/vit-Facial-Expression-Recognition.
"""

import numpy as np
from PIL import Image
import io
from typing import Dict
import logging

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

# Model label mapping (id -> label) as returned by the ViT model.
# The model has 7 classes: angry, disgust, fear, happy, sad, surprise, neutral
MODEL_LABELS = {
    0: "angry",
    1: "disgust",
    2: "fear",
    3: "happy",
    4: "sad",
    5: "surprise",
    6: "neutral",
}

# Map model labels to app-friendly emotion names (7 emotions)
MODEL_TO_APP = {
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
        model_name: str = "mo-thecreator/vit-Facial-Expression-Recognition",
    ):
        self.model_name = model_name
        self.model = None
        self.processor = None
        self.initialized = False
        self._load_error = None

        if TRANSFORMERS_AVAILABLE:
            self._load_model()

    def _load_model(self):
        """Load the ViT model and processor from HuggingFace."""
        try:
            logger.info(f"Loading emotion model: {self.model_name}")
            self.processor = ViTImageProcessor.from_pretrained(self.model_name)
            self.model = ViTForImageClassification.from_pretrained(self.model_name)
            self.model.eval()  # Set to evaluation mode
            self.initialized = True
            logger.info("Emotion model loaded successfully")

        except Exception as e:
            self._load_error = str(e)
            logger.error(f"Failed to load emotion model: {e}")

    def is_ready(self) -> bool:
        """Check if model is loaded and ready."""
        return (
            self.initialized
            and self.model is not None
            and self.processor is not None
        )

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

    def classify(self, image_bytes: bytes) -> Dict:
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

        model_label = MODEL_LABELS.get(max_idx, "neutral")
        app_emotion = MODEL_TO_APP.get(model_label, "Calm")

        # Build all probabilities dict
        all_probs = {
            MODEL_LABELS.get(i, f"class_{i}"): float(probabilities[i])
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
