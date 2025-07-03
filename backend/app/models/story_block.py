from datetime import datetime
from pydantic import BaseModel

class StoryBlock(BaseModel):
    id: int
    story_owner: str
    hidden_user: str
    created_at: datetime

class StoryBlockCreate(BaseModel):
    story_owner: str
    hidden_user: str
