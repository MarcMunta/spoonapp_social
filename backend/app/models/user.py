from pydantic import BaseModel


class UserProfile(BaseModel):
    username: str
    bio: str = ""
    avatar_url: str | None = None
    bubble_color: str | None = None

class LoginRequest(BaseModel):
    username: str
    password: str


class User(UserProfile):
    password: str


class ProfileUpdate(BaseModel):
    bio: str | None = None
    avatar_url: str | None = None
    bubble_color: str | None = None
