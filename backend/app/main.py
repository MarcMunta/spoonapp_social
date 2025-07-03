
from fastapi import FastAPI, HTTPException
from typing import List

from .models import Post, Story, LoginRequest
from .data import fake_posts, fake_stories

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


@app.post("/login")
def login(data: LoginRequest):
    """Simple login endpoint that accepts any username with password 'password'."""
    if data.password == "password":
        return {"token": "fake-token", "username": data.username}
    raise HTTPException(status_code=400, detail="Invalid credentials")
