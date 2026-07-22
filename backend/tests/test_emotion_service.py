import io
import unittest
from types import SimpleNamespace
from unittest.mock import patch

import numpy as np
from PIL import Image

from app.services.emotion_service import EmotionService


class _NoGrad:
    def __enter__(self):
        return None

    def __exit__(self, exc_type, exc_value, traceback):
        return False


class _FakeTorch:
    @staticmethod
    def no_grad():
        return _NoGrad()


class _FakeVector:
    def __init__(self, values):
        self._values = values

    def cpu(self):
        return self

    def numpy(self):
        return np.array(self._values, dtype=np.float32)


class _FakeLogits:
    def __init__(self, values):
        self._values = values

    def __getitem__(self, index):
        return _FakeVector(self._values[index])


class _FakeModel:
    def __init__(self, logits):
        self.config = SimpleNamespace(
            id2label={
                "0": "anger",
                "1": "disgust",
                "2": "fear",
                "3": "happy",
                "4": "neutral",
                "5": "sad",
                "6": "surprise",
            }
        )
        self._logits = logits

    def __call__(self, **inputs):
        return SimpleNamespace(logits=_FakeLogits([self._logits]))


class _FakeProcessor:
    def __call__(self, images, return_tensors):
        return {"pixel_values": "prepared"}


class EmotionServiceTest(unittest.TestCase):
    def test_classify_uses_model_label_configuration(self):
        service = EmotionService.__new__(EmotionService)
        service.model_name = "test-model"
        service.model = _FakeModel([0.1, 0.1, 0.1, 0.1, 3.0, 0.1, 0.1])
        service.processor = _FakeProcessor()
        service.initialized = True
        service._load_error = None

        image_buffer = io.BytesIO()
        Image.new("RGB", (8, 8), color="white").save(image_buffer, format="PNG")

        with patch("app.services.emotion_service.torch", _FakeTorch(), create=True):
            result = service.classify(image_buffer.getvalue())

        self.assertEqual(result["model_label"], "neutral")
        self.assertEqual(result["detected_emotion"], "Calm")
        self.assertGreater(result["confidence"], 0.5)
        self.assertEqual(
            list(result["all_probabilities"]),
            ["anger", "disgust", "fear", "happy", "neutral", "sad", "surprise"],
        )

    def test_classify_rejects_when_model_is_not_ready(self):
        service = EmotionService.__new__(EmotionService)
        service.model = None
        service.processor = None
        service.initialized = False
        service._load_error = "Model unavailable"

        with self.assertRaisesRegex(RuntimeError, "Model unavailable"):
            service.classify(b"not-used")


if __name__ == "__main__":
    unittest.main()
