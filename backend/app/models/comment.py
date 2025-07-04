from pydantic import BaseModel
from datetime import datetime

class Comment(BaseModel):
    id: int
    post_id: int
    user: str
    content: str
    created_at: datetime
    bubble_color: str | None = None

class CommentRequest(BaseModel):
    user: str
    content: str
