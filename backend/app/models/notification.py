from pydantic import BaseModel
from datetime import datetime

class Notification(BaseModel):
    id: int
    message: str
    created_at: datetime
    title: str | None = None
    notification_type: str | None = None
    is_read: bool = False
    related_user: str | None = None
    related_chat: int | None = None
    target_url: str | None = None
