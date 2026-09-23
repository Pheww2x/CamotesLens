"""
utils/validators.py
-------------------
File-upload validation utilities for the CamotesLens API.
"""

import os

# Maximum accepted file size: 10 MB
MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024

# Allowed MIME types and extensions
ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png"}
ALLOWED_MIME_TYPES = {"image/jpeg", "image/png"}


def get_extension(filename: str) -> str:
    """Return the lower-cased extension (without dot) of *filename*."""
    return os.path.splitext(filename)[1].lstrip(".").lower()


def is_allowed_file(filename: str) -> bool:
    """Return True if *filename* has an accepted image extension."""
    return get_extension(filename) in ALLOWED_EXTENSIONS


def validate_upload(file) -> tuple[bool, str]:
    """
    Validate a werkzeug FileStorage object.

    Returns
    -------
    (True, "")            – file is valid
    (False, error_msg)    – file is invalid; error_msg describes the problem
    """
    if file is None:
        return False, "No file was provided."

    filename = file.filename or ""
    if filename == "":
        return False, "The uploaded file has no filename."

    if not is_allowed_file(filename):
        ext = get_extension(filename)
        return (
            False,
            f"Unsupported file type '.{ext}'. Please upload a JPEG or PNG image.",
        )

    # Check content-type header when available
    content_type = getattr(file, "content_type", None) or getattr(
        file, "mimetype", None
    )
    if content_type and content_type not in ALLOWED_MIME_TYPES:
        return (
            False,
            f"Unsupported content type '{content_type}'. "
            "Please upload a JPEG or PNG image.",
        )

    # Read file bytes to check size, then seek back to the beginning
    file.seek(0, os.SEEK_END)
    size = file.tell()
    file.seek(0)

    if size == 0:
        return False, "The uploaded file is empty."

    if size > MAX_FILE_SIZE_BYTES:
        mb = size / (1024 * 1024)
        return (
            False,
            f"File size ({mb:.1f} MB) exceeds the 10 MB limit. "
            "Please upload a smaller image.",
        )

    return True, ""
