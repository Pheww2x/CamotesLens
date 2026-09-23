"""
tests/test_api.py
-----------------
Integration tests for the CamotesLens Flask API.

These tests use a mocked predictor so they run WITHOUT a real TensorFlow model.
Run with: python -m pytest tests/ -v
"""

import io
import json
import sys
from pathlib import Path
from unittest.mock import patch, MagicMock

import pytest

# Make backend root importable
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))


# ── Patch predictor before importing app ──────────────────────────────────────
# We mock predictor.initialize so the app doesn't try to load a real .keras file
_mock_predictor = MagicMock()
_mock_predictor.get_class_names.return_value = [
    "PSBSP-1", "PSBSP-2", "PSBSP-3", "PSBSP-4"
]
_mock_predictor.predict.return_value = {
    "predicted_class": "PSBSP-1",
    "confidence": 0.94,
    "probabilities": {
        "PSBSP-1": 0.94,
        "PSBSP-2": 0.03,
        "PSBSP-3": 0.02,
        "PSBSP-4": 0.01,
    },
}
_mock_predictor.initialize.return_value = None

sys.modules["services.predictor"] = _mock_predictor

from app import app as flask_app


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------


@pytest.fixture
def client():
    flask_app.config["TESTING"] = True
    with flask_app.test_client() as c:
        yield c


def _make_jpeg_bytes() -> bytes:
    """Return a minimal valid JPEG byte sequence."""
    # 1×1 white JPEG (25 bytes) — valid enough for Content-Type checks
    return bytes([
        0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00,
        0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xD9,
    ])


def _post_image(client, image_bytes=None, filename="leaf.jpg",
                content_type="image/jpeg"):
    if image_bytes is None:
        image_bytes = _make_jpeg_bytes()
    return client.post(
        "/predict",
        data={"image": (io.BytesIO(image_bytes), filename, content_type)},
        content_type="multipart/form-data",
    )


# ---------------------------------------------------------------------------
# /health endpoint
# ---------------------------------------------------------------------------


def test_health_returns_ok(client):
    with patch("app.predictor.get_class_names",
               return_value=["PSBSP-1", "PSBSP-2", "PSBSP-3", "PSBSP-4"]):
        resp = client.get("/health")
    assert resp.status_code == 200
    data = resp.get_json()
    assert data["status"] == "ok"


# ---------------------------------------------------------------------------
# /predict — valid requests
# ---------------------------------------------------------------------------


def test_predict_returns_success_json(client):
    with patch("app.predictor.predict", return_value={
        "predicted_class": "PSBSP-1",
        "confidence": 0.94,
        "probabilities": {
            "PSBSP-1": 0.94, "PSBSP-2": 0.03,
            "PSBSP-3": 0.02, "PSBSP-4": 0.01,
        },
    }):
        resp = _post_image(client)

    assert resp.status_code == 200
    data = resp.get_json()
    assert data["success"] is True
    assert "predicted_class" in data
    assert "confidence" in data
    assert "probabilities" in data


def test_predict_accepts_png(client):
    with patch("app.predictor.predict", return_value={
        "predicted_class": "PSBSP-2",
        "confidence": 0.80,
        "probabilities": {"PSBSP-2": 0.80, "PSBSP-1": 0.20},
    }):
        resp = _post_image(client, filename="leaf.png",
                           content_type="image/png")
    assert resp.status_code == 200


# ---------------------------------------------------------------------------
# /predict — invalid requests
# ---------------------------------------------------------------------------


def test_predict_no_file_returns_400(client):
    resp = client.post("/predict", content_type="multipart/form-data")
    assert resp.status_code == 400
    data = resp.get_json()
    assert data["success"] is False
    assert "error" in data


def test_predict_empty_filename_returns_400(client):
    resp = client.post(
        "/predict",
        data={"image": (io.BytesIO(b"data"), "", "image/jpeg")},
        content_type="multipart/form-data",
    )
    assert resp.status_code == 400


def test_predict_unsupported_extension_returns_400(client):
    resp = _post_image(client, filename="leaf.gif",
                       content_type="image/gif")
    assert resp.status_code == 400
    data = resp.get_json()
    assert data["success"] is False


def test_predict_empty_file_returns_400(client):
    resp = _post_image(client, image_bytes=b"")
    assert resp.status_code == 400
    data = resp.get_json()
    assert data["success"] is False


def test_predict_model_error_returns_500(client):
    with patch("app.predictor.predict", side_effect=RuntimeError("GPU error")):
        resp = _post_image(client)
    assert resp.status_code == 500
    data = resp.get_json()
    assert data["success"] is False


# ---------------------------------------------------------------------------
# JSON response format
# ---------------------------------------------------------------------------


def test_response_has_correct_schema(client):
    with patch("app.predictor.predict", return_value={
        "predicted_class": "PSBSP-1",
        "confidence": 0.94,
        "probabilities": {"PSBSP-1": 0.94, "PSBSP-2": 0.06},
    }):
        resp = _post_image(client)

    data = resp.get_json()
    assert isinstance(data["success"], bool)
    assert isinstance(data["predicted_class"], str)
    assert isinstance(data["confidence"], float)
    assert isinstance(data["probabilities"], dict)
    # All probability values must be floats
    for k, v in data["probabilities"].items():
        assert isinstance(k, str)
        assert isinstance(v, float)
