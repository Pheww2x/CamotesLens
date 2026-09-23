"""
tests/test_validators.py
------------------------
Unit tests for the upload validation utilities.
Run with:  python -m pytest tests/ -v
"""

import io
import pytest

# We need to add the parent directory to sys.path so the backend package resolves
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from utils.validators import validate_upload


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


class _FakeFile:
    """Minimal stand-in for a werkzeug FileStorage object."""

    def __init__(self, filename: str, content: bytes, content_type: str = "image/jpeg"):
        self.filename = filename
        self.content_type = content_type
        self._data = io.BytesIO(content)

    def seek(self, pos, whence=0):
        self._data.seek(pos, whence)

    def tell(self):
        return self._data.tell()

    def read(self):
        return self._data.read()


def _make_file(filename="leaf.jpg", size_bytes=1024, content_type="image/jpeg"):
    content = b"x" * size_bytes
    return _FakeFile(filename, content, content_type)


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------


def test_valid_jpeg():
    f = _make_file("leaf.jpg")
    ok, msg = validate_upload(f)
    assert ok is True
    assert msg == ""


def test_valid_png():
    f = _make_file("leaf.png", content_type="image/png")
    ok, msg = validate_upload(f)
    assert ok is True


def test_valid_jpeg_uppercase():
    f = _make_file("LEAF.JPEG")
    ok, msg = validate_upload(f)
    assert ok is True


def test_none_file():
    ok, msg = validate_upload(None)
    assert ok is False
    assert "No file" in msg


def test_empty_filename():
    f = _make_file("")
    f.filename = ""
    ok, msg = validate_upload(f)
    assert ok is False


def test_unsupported_extension():
    f = _make_file("leaf.gif", content_type="image/gif")
    ok, msg = validate_upload(f)
    assert ok is False
    assert "gif" in msg.lower() or "Unsupported" in msg


def test_empty_file():
    f = _make_file(size_bytes=0)
    ok, msg = validate_upload(f)
    assert ok is False
    assert "empty" in msg.lower()


def test_file_too_large():
    size = 11 * 1024 * 1024  # 11 MB
    f = _make_file(size_bytes=size)
    ok, msg = validate_upload(f)
    assert ok is False
    assert "10 MB" in msg or "limit" in msg.lower()
