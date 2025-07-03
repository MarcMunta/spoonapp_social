from pydantic import BaseModel
from datetime import datetime

class Comment(BaseModel):
    id: int
    post_id: int
    user: str
    content: str
    created_at: datetime

class CommentRequest(BaseModel):
    user: str
    content: str
