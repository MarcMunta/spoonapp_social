from pydantic import BaseModel

class LikeRequest(BaseModel):
    user: str
