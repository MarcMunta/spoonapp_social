from datetime import datetime
from pydantic import BaseModel

class Block(BaseModel):
    id: int
    blocker: str
    blocked: str
    created_at: datetime

class BlockCreate(BaseModel):
    blocker: str
    blocked: str
