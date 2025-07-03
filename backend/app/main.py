from fastapi import FastAPI, HTTPException
from typing import List

from .models import Post, Story, Notification, LoginRequest, User
from .data import fake_posts, fake_stories, fake_notifications, fake_users

app = FastAPI(title="SpoonApp API")

@app.get("/")
def read_root():
    return {"message": "SpoonApp API"}


@app.get("/posts", response_model=List[Post])
def list_posts():
    """Return sample list of posts."""
    return fake_posts


@app.get("/stories", response_model=List[Story])
def list_stories():
    """Return sample list of stories."""
    return fake_stories


@app.get("/notifications", response_model=List[Notification])
def list_notifications():
    """Return sample list of notifications."""
    return fake_notifications


@app.post("/login")
def login(data: LoginRequest):
    """Simple login endpoint that validates against fake_users."""
    for user in fake_users:
        if user.username == data.username and user.password == data.password:
            return {"token": "fake-token", "username": user.username}
    raise HTTPException(status_code=400, detail="Invalid credentials")


@app.post("/signup")
def signup(data: LoginRequest):
    """Create a new fake user if the username is free."""
    if any(u.username == data.username for u in fake_users):
        raise HTTPException(status_code=400, detail="Username taken")
    user = User(username=data.username, password=data.password)
    fake_users.append(user)
    return {"token": "fake-token", "username": user.username}
