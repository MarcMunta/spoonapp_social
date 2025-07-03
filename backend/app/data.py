from datetime import datetime
from .models import Post, Story

fake_posts = [
    Post(id=1, user="alice", caption="Hello World", created_at=datetime.utcnow(), image_url="https://placehold.co/600x400"),
    Post(id=2, user="bob", caption="Second Post", created_at=datetime.utcnow())
]

fake_stories = [
    Story(id=1, user="alice", image_url="https://placehold.co/100x100", created_at=datetime.utcnow()),
    Story(id=2, user="bob", image_url="https://placehold.co/100x100", created_at=datetime.utcnow()),
]
