import unittest
from unittest.mock import MagicMock, patch

from app.config import settings
from app.services import emotion_service


class EmotionActivationTest(unittest.TestCase):
    def test_default_disabled_does_not_download(self):
        with patch.object(settings, "EMOTION_MODEL_ENABLED", False), patch.object(
            emotion_service, "ViTImageProcessor", create=True
        ) as processor:
            service = emotion_service.EmotionService()
            self.assertFalse(service.is_ready())
            processor.from_pretrained.assert_not_called()

    def test_enabled_loads_existing_model_and_enters_eval_mode(self):
        model = MagicMock()
        processor = MagicMock()
        with patch.object(settings, "EMOTION_MODEL_ENABLED", True), patch.object(
            emotion_service, "TRANSFORMERS_AVAILABLE", True
        ), patch.object(emotion_service, "ViTImageProcessor", create=True) as processor_type, patch.object(
            emotion_service, "ViTForImageClassification", create=True
        ) as model_type:
            processor_type.from_pretrained.return_value = processor
            model_type.from_pretrained.return_value = model
            service = emotion_service.EmotionService()
            self.assertTrue(service.is_ready())
            model_type.from_pretrained.assert_called_once_with(
                "mo-thecreator/vit-Facial-Expression-Recognition", use_safetensors=True
            )
            model.eval.assert_called_once()
            self.assertIsNone(service._load_error)

    def test_failed_download_remains_unavailable_without_raw_error(self):
        with patch.object(settings, "EMOTION_MODEL_ENABLED", True), patch.object(
            emotion_service, "TRANSFORMERS_AVAILABLE", True
        ), patch.object(emotion_service, "ViTImageProcessor", create=True) as processor_type, self.assertLogs(
            emotion_service.logger, level="ERROR"
        ):
            processor_type.from_pretrained.side_effect = RuntimeError("private server details")
            service = emotion_service.EmotionService()
            self.assertFalse(service.is_ready())
            self.assertNotIn("private server details", service._load_error)
            self.assertIsNone(service.model)


if __name__ == "__main__":
    unittest.main()
