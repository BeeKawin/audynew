import unittest
from unittest.mock import patch

from fastapi import FastAPI
from fastapi.testclient import TestClient

from app.config import settings
from app.cors import configure_cors


class WebCorsTest(unittest.TestCase):
    def setUp(self):
        self.app = FastAPI()
        with patch.object(settings, "CORS_ORIGINS", ["https://audy.example"]), patch.object(
            settings, "CORS_ORIGIN_REGEX", r"https://audy-preview-[a-z0-9]+\.vercel\.app"
        ):
            configure_cors(self.app)
            # Starlette constructs middleware lazily.
            self.client = TestClient(self.app)
            self.client.get("/")

    def preflight(self, origin):
        return self.client.options("/api/emotion/classify", headers={
            "Origin": origin,
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "content-type",
        })

    def test_production_origin(self):
        result = self.preflight("https://audy.example")
        self.assertEqual(result.status_code, 200)
        self.assertEqual(result.headers["access-control-allow-origin"], "https://audy.example")

    def test_approved_preview(self):
        self.assertEqual(self.preflight("https://audy-preview-123.vercel.app").status_code, 200)

    def test_unrelated_vercel_origin_is_rejected(self):
        result = self.preflight("https://someone-else.vercel.app")
        self.assertEqual(result.status_code, 400)
        self.assertNotIn("access-control-allow-origin", result.headers)

    def test_native_request_needs_no_cors(self):
        self.assertEqual(self.client.get("/").status_code, 404)


if __name__ == "__main__":
    unittest.main()
