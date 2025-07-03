from fastapi import FastAPI
from typing import List

from .models import Post, Story
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
