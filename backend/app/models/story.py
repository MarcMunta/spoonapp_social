from pydantic import BaseModel
from datetime import datetime

class Story(BaseModel):
    id: int
    user: str
    image_url: str
    created_at: datetime
