from pydantic import BaseModel
from datetime import datetime
from typing import List

class Chat(BaseModel):
    id: int
    participants: List[str]
    created_at: datetime

class Message(BaseModel):
    id: int
    chat_id: int
    sender: str
    content: str
    created_at: datetime

class MessageRequest(BaseModel):
    sender: str
    content: str
