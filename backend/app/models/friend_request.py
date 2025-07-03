from datetime import datetime
from pydantic import BaseModel


class FriendRequest(BaseModel):
    id: int
    from_user: str
    to_user: str
    created_at: datetime


class FriendRequestCreate(BaseModel):
    from_user: str
    to_user: str
