"""
services/preprocessing.py
--------------------------
Image-preprocessing pipeline for CamotesLens inference.

IMPORTANT
---------
This pipeline MUST match the preprocessing applied to training images.
EfficientNetB0 was pretrained on ImageNet and expects inputs preprocessed
with `tf.keras.applications.efficientnet.preprocess_input`, which scales
pixel values to the range [-1, 1].  Do NOT change the normalization here
without also retraining or fine-tuning the model with the new preprocessing.
"""

import numpy as np
from PIL import Image
import tensorflow as tf

# Target spatial dimensions expected by EfficientNetB0
TARGET_SIZE = (224, 224)


def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """
    Load raw image bytes and return a preprocessed batch tensor ready
    for EfficientNetB0 inference.

    Steps
    -----
    1. Decode bytes → PIL Image
    2. Convert to RGB (handles RGBA, grayscale, palette modes)
    3. Resize to 224 × 224 using high-quality LANCZOS resampling
    4. Convert to float32 numpy array  (H, W, C)
    5. Apply EfficientNetB0 preprocessing  (scales to [-1, 1])
    6. Add batch dimension  →  (1, 224, 224, 3)

    Parameters
    ----------
    image_bytes : bytes
        Raw bytes of a JPEG or PNG image file.

    Returns
    -------
    np.ndarray
        Shape (1, 224, 224, 3), dtype float32.
    """
    import io

    pil_image = Image.open(io.BytesIO(image_bytes))

    # Ensure three-channel RGB regardless of source mode
    if pil_image.mode != "RGB":
        pil_image = pil_image.convert("RGB")

    # Resize to the model's expected spatial input
    pil_image = pil_image.resize(TARGET_SIZE, Image.LANCZOS)

    # Convert to float32 numpy array in [0, 255]
    img_array = np.array(pil_image, dtype=np.float32)

    # Apply the SAME normalization used during training:
    # tf.keras.applications.efficientnet.preprocess_input scales [0,255] → [-1,1]
    img_array = tf.keras.applications.efficientnet.preprocess_input(img_array)

    # Add batch dimension: (H, W, C) → (1, H, W, C)
    img_array = np.expand_dims(img_array, axis=0)

    return img_array
