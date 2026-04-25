"""
Emotion Classification Service using ONNX Runtime.
Loads the converted emotion model and provides inference.
"""

import numpy as np
from PIL import Image
import io
from typing import Dict, List
import logging

logger = logging.getLogger(__name__)

# Try to import onnxruntime, provide fallback if not available
try:
    import onnxruntime as ort

    ONNX_AVAILABLE = True
except ImportError:
    ONNX_AVAILABLE = False
    logger.warning("onnxruntime not installed. Emotion classification will not work.")

# Model mappings (same as Flutter app)
MODEL_LABELS = {
    0: "Happy",
    1: "Sad",
    2: "Surprised",
    3: "Fearful",
    4: "Angry",
    5: "Disgusted",
    6: "Neutral",
}

MODEL_TO_APP = {
    "Angry": "Angry",
    "Fearful": "Scared",
    "Happy": "Happy",
    "Neutral": "Calm",
    "Sad": "Sad",
    "Surprised": "Surprised",
    "Disgusted": "Scared",
}

MIN_CONFIDENCE = 0.4
INPUT_SIZE = 48


class EmotionService:
    """ONNX-based emotion classification service."""

    def __init__(self, model_path: str = "models/model.onnx"):
        self.model_path = model_path
        self.session = None
        self.initialized = False
        self._load_error = None

        if ONNX_AVAILABLE:
            self._load_model()

    def _load_model(self):
        """Load the ONNX model."""
        try:
            # Create inference session with CPU provider
            self.session = ort.InferenceSession(
                self.model_path, providers=["CPUExecutionProvider"]
            )
            self.initialized = True
            logger.info(f"Emotion model loaded from {self.model_path}")

            # Log model info
            input_name = self.session.get_inputs()[0].name
            input_shape = self.session.get_inputs()[0].shape
            logger.info(f"Model input: {input_name}, shape: {input_shape}")

        except Exception as e:
            self._load_error = str(e)
            logger.error(f"Failed to load emotion model: {e}")

    def is_ready(self) -> bool:
        """Check if model is loaded and ready."""
        return self.initialized and self.session is not None

    def preprocess(self, image_bytes: bytes) -> np.ndarray:
        """
        Preprocess image for model inference.

        Args:
            image_bytes: Raw image bytes (JPEG/PNG)

        Returns:
            Preprocessed numpy array [1, 48, 48, 3]
        """
        # Load image from bytes
        image = Image.open(io.BytesIO(image_bytes))

        # Convert to RGB if needed
        if image.mode != "RGB":
            image = image.convert("RGB")

        # Resize to model input size
        image = image.resize((INPUT_SIZE, INPUT_SIZE), Image.Resampling.LANCZOS)

        # Convert to numpy array and normalize
        img_array = np.array(image, dtype=np.float32)
        img_array = img_array / 255.0  # Normalize to 0-1

        # Add batch dimension: [48, 48, 3] -> [1, 48, 48, 3]
        img_array = np.expand_dims(img_array, axis=0)

        return img_array

    def softmax(self, x: np.ndarray) -> np.ndarray:
        """Apply softmax activation."""
        exp_x = np.exp(x - np.max(x))
        return exp_x / exp_x.sum()

    def classify(self, image_bytes: bytes) -> Dict:
        """
        Classify emotion from image.

        Args:
            image_bytes: Raw image bytes

        Returns:
            Dict with detected_emotion, confidence, all_probabilities
        """
        if not self.is_ready():
            raise RuntimeError(
                f"Emotion model not loaded. Error: {self._load_error or 'Unknown'}"
            )

        # Preprocess
        input_data = self.preprocess(image_bytes)

        # Get input name
        input_name = self.session.get_inputs()[0].name

        # Run inference
        outputs = self.session.run(None, {input_name: input_data})

        # Process outputs
        logits = outputs[0][0]  # Remove batch dimension
        probabilities = self.softmax(logits)

        # Get prediction
        max_idx = int(np.argmax(probabilities))
        max_conf = float(probabilities[max_idx])

        model_label = MODEL_LABELS.get(max_idx, "Neutral")
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
