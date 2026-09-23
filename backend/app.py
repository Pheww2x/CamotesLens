"""
app.py
------
CamotesLens — Sweet Potato Variety Classification API
Flask REST API entry point.
"""

import logging
import os

from flask import Flask, jsonify, request
from flask_cors import CORS

from services import predictor
from services.predictor_errors import LowConfidencePrediction
from utils.validators import validate_upload

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s — %(message)s",
)
logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Flask application
# ---------------------------------------------------------------------------
app = Flask(__name__)
CORS(app)  # Allow cross-origin requests from the Flutter debug build

# Maximum upload size: 10 MB (also enforced in the validator)
app.config["MAX_CONTENT_LENGTH"] = 10 * 1024 * 1024


# ---------------------------------------------------------------------------
# Start-up: load model and class names ONCE
# ---------------------------------------------------------------------------
with app.app_context():
    predictor.initialize()


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------


@app.get("/health")
def health():
    """Quick liveness check. Returns class names so clients can verify config."""
    return jsonify(
        {
            "status": "ok",
            "class_names": predictor.get_class_names(),
            "num_classes": len(predictor.get_class_names()),
        }
    )


@app.post("/predict")
def predict():
    """
    POST /predict
    -------------
    Accepts a multipart/form-data request with field `image` (JPEG or PNG).
    Returns a JSON object with the predicted sweet potato variety.

    Success response (HTTP 200)
    ---------------------------
    {
        "success": true,
        "predicted_class": "VARIETY_NAME",
        "confidence": 0.94,
        "probabilities": {
            "VARIETY_1": 0.94,
            "VARIETY_2": 0.03,
            ...
        }
    }

    Error response (HTTP 4xx / 5xx)
    --------------------------------
    {
        "success": false,
        "error": "Human-readable error message."
    }
    """
    # ── 1. Check that the request contains a file ──────────────────────────
    if "image" not in request.files:
        return (
            jsonify({"success": False, "error": "No image field found in the request."}),
            400,
        )

    file = request.files["image"]

    # ── 2. Validate the uploaded file ──────────────────────────────────────
    valid, error_message = validate_upload(file)
    if not valid:
        return jsonify({"success": False, "error": error_message}), 400

    # ── 3. Read file bytes (file pointer is already at 0 after validation) ──
    image_bytes = file.read()

    # ── 4. Run prediction ──────────────────────────────────────────────────
    try:
        result = predictor.predict(image_bytes)
    except LowConfidencePrediction as exc:
        return jsonify({"success": False, "error": str(exc)}), 422
    except Exception as exc:  # noqa: BLE001
        logger.exception("Prediction failed: %s", exc)
        return (
            jsonify(
                {
                    "success": False,
                    "error": (
                        "The classification model encountered an error while "
                        "processing the image. Please try again with a different image."
                    ),
                }
            ),
            500,
        )

    # ── 5. Return structured response ──────────────────────────────────────
    return jsonify(
        {
            "success": True,
            "predicted_class": result["predicted_class"],
            "confidence": result["confidence"],
            "probabilities": result["probabilities"],
        }
    )


# ---------------------------------------------------------------------------
# Error handlers
# ---------------------------------------------------------------------------


@app.errorhandler(413)
def request_entity_too_large(_error):
    return (
        jsonify(
            {
                "success": False,
                "error": "The uploaded file is too large. Maximum allowed size is 10 MB.",
            }
        ),
        413,
    )


@app.errorhandler(404)
def not_found(_error):
    return jsonify({"success": False, "error": "Endpoint not found."}), 404


@app.errorhandler(405)
def method_not_allowed(_error):
    return jsonify({"success": False, "error": "Method not allowed."}), 405


# ---------------------------------------------------------------------------
# Development entry point
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    debug = os.environ.get("FLASK_DEBUG", "false").lower() == "true"
    logger.info("Starting CamotesLens API on port %d (debug=%s)", port, debug)
    app.run(host="0.0.0.0", port=port, debug=debug)
