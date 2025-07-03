from pydantic import BaseModel
from datetime import datetime

class Notification(BaseModel):
    id: int
    message: str
    created_at: datetime
