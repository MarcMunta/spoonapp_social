import base64


def _b64decode_padded(data: str) -> bytes:
    """Return decoded bytes even if the input is missing padding."""
    missing = len(data) % 4
    if missing:
        data += "=" * (4 - missing)
    return base64.b64decode(data)

DEFAULT_AVATAR_BASE64 = (
    "iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAIAAAD/gAIDAAAA6ElEQVR4nO3QwQ3AIBDAsNLJb3RWIC+E"
    "ZE8QZc3Mx5n/dsBLzArMCswKzArMCswKzArMCswKzArMCswKzArMCswKzArMCswKzArMCswKzArMCswK"
    "zArMCswKzArMCswKzArMCswKzArMCswKzArMCswKzArMCswKzArMCswKzArMCswKzArMCswKzArMCswK"
    "zArMCswKzArMCswKzArMCswKzArMCswKzArMCswKzArMCswKzArMCswKzArMCswKzArMCswKzArMCswK"
    "zArMCswKzArMCswKzArMCswKzArMCswKzArMCjbLZgJIjFtsAQAAAABJRU5ErkJggg=="
)

DEFAULT_AVATAR_BYTES = _b64decode_padded(DEFAULT_AVATAR_BASE64)
DEFAULT_AVATAR_DATA_URL = f"data:image/png;base64,{DEFAULT_AVATAR_BASE64}"
