"""
services/predictor.py
---------------------
Model-loading and prediction service for CamotesLens.

The TensorFlow model is loaded ONCE at application start-up so that every
prediction request reuses the same in-memory model, avoiding repeated
disk I/O and graph compilation overhead.
"""

import json
import logging
import os
import tempfile
import zipfile
from pathlib import Path

import numpy as np
import tensorflow as tf

from services.preprocessing import preprocess_image
from services.predictor_errors import LowConfidencePrediction

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
_BASE_DIR = Path(__file__).resolve().parent.parent
_MODEL_PATH = _BASE_DIR / "model" / "trained_model.keras"
_CLASS_NAMES_PATH = _BASE_DIR / "class_names.json"

# ---------------------------------------------------------------------------
# Module-level singletons (loaded once at import / server start)
# ---------------------------------------------------------------------------
_model: tf.keras.Model | None = None
_class_names: list[str] = []
CONFIDENCE_THRESHOLD = 0.70


def _remove_optional_quantization_config(value):
    if isinstance(value, dict):
        value.pop("quantization_config", None)
        for child in value.values():
            _remove_optional_quantization_config(child)
    elif isinstance(value, list):
        for child in value:
            _remove_optional_quantization_config(child)


def _load_class_names() -> list[str]:
    """Load variety class names from class_names.json."""
    if not _CLASS_NAMES_PATH.exists():
        raise FileNotFoundError(
            f"class_names.json not found at '{_CLASS_NAMES_PATH}'. "
            "Please create this file with your variety labels."
        )
    with open(_CLASS_NAMES_PATH, "r", encoding="utf-8") as f:
        names = json.load(f)
    if not isinstance(names, list) or len(names) == 0:
        raise ValueError("class_names.json must be a non-empty JSON array of strings.")
    logger.info("Loaded %d class names: %s", len(names), names)
    return names


def _load_model() -> tf.keras.Model:
    """Load the trained Keras model from disk."""
    if not _MODEL_PATH.exists():
        raise FileNotFoundError(
            f"Trained model not found at '{_MODEL_PATH}'. "
            "Please copy your trained_model.keras file into the backend/model/ directory."
        )
    logger.info("Loading model from '%s' …", _MODEL_PATH)
    try:
        return tf.keras.models.load_model(str(_MODEL_PATH))
    except (TypeError, ValueError) as exc:
        if "quantization_config" not in str(exc):
            raise

        with zipfile.ZipFile(_MODEL_PATH, "r") as source:
            config = json.loads(source.read("config.json"))
            _remove_optional_quantization_config(config)
            with tempfile.NamedTemporaryFile(suffix=".keras", delete=False) as target:
                temporary_path = target.name

            try:
                with zipfile.ZipFile(temporary_path, "w") as destination:
                    for item in source.infolist():
                        data = (
                            json.dumps(config).encode("utf-8")
                            if item.filename == "config.json"
                            else source.read(item.filename)
                        )
                        destination.writestr(item, data)
                return tf.keras.models.load_model(temporary_path)
            finally:
                os.unlink(temporary_path)
    logger.info(
        "Model loaded successfully. Input shape: %s  Output shape: %s",
        model.input_shape,
        model.output_shape,
    )
    return model


def initialize() -> None:
    """
    Load the model and class names into module-level singletons.
    Call this once when the Flask/FastAPI application starts.
    """
    global _model, _class_names
    _class_names = _load_class_names()
    _model = _load_model()

    # Sanity-check: number of model outputs must equal number of class names
    num_outputs = _model.output_shape[-1]
    if num_outputs != len(_class_names):
        raise ValueError(
            f"Model output size ({num_outputs}) does not match the number of "
            f"class names ({len(_class_names)}) in class_names.json. "
            "Ensure class_names.json lists exactly one name per output unit "
            "in the same order used during training."
        )


def predict(image_bytes: bytes) -> dict:
    """
    Run EfficientNetB0 inference on the supplied image bytes.

    Parameters
    ----------
    image_bytes : bytes
        Raw JPEG or PNG bytes from the uploaded file.

    Returns
    -------
    dict with keys:
        predicted_class : str
        confidence      : float  (0.0 – 1.0)
        probabilities   : dict[str, float]
    """
    if _model is None or not _class_names:
        raise RuntimeError(
            "Predictor has not been initialized. "
            "Call predictor.initialize() before making predictions."
        )

    # Preprocess ─ same pipeline as training
    img_array = preprocess_image(image_bytes)

    # Inference
    predictions = _model.predict(img_array, verbose=0)  # shape: (1, num_classes)
    probabilities = predictions[0].tolist()             # list of float

    # Determine best class
    best_idx = int(np.argmax(probabilities))
    predicted_class = _class_names[best_idx]
    confidence = float(probabilities[best_idx])

    if confidence < CONFIDENCE_THRESHOLD:
        raise LowConfidencePrediction(
            "Unable to confidently identify the variety. "
            "Please capture a clear sweet potato leaf."
        )

    # Build named probability map (sorted descending by probability for the API)
    prob_map = {
        name: round(float(prob), 6)
        for name, prob in zip(_class_names, probabilities)
    }

    return {
        "predicted_class": predicted_class,
        "confidence": round(confidence, 6),
        "probabilities": prob_map,
    }


def get_class_names() -> list[str]:
    """Return the loaded class names (useful for health-check endpoints)."""
    return list(_class_names)


