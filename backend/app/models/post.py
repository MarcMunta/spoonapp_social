from pydantic import BaseModel
from datetime import datetime

class Post(BaseModel):
    id: int
    user: str
    caption: str
    created_at: datetime
    image_url: str | None = None
    video_url: str | None = None
    likes: int = 0
    liked: bool = False
    categories: list[str] = []
    bubble_color: str | None = None


class PostRequest(BaseModel):
    user: str
    caption: str
    image_url: str | None = None
    categories: list[str] = []
