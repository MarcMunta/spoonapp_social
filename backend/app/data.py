from datetime import datetime
from .models import (
    Post,
    Story,
    User,
    Notification,
    Comment,
    Chat,
    Message,
)

fake_posts = [
    Post(
        id=1,
        user="alice",
        caption="Hello World",
        created_at=datetime.utcnow(),
        image_url="https://placehold.co/600x400",
        likes=1,
    ),
    Post(id=2, user="bob", caption="Second Post", created_at=datetime.utcnow(), likes=0),
]

fake_users = [
    User(username="alice", password="password"),
    User(username="bob", password="password"),
]

fake_stories = [
    Story(id=1, user="alice", image_url="https://placehold.co/100x100", created_at=datetime.utcnow()),
    Story(id=2, user="bob", image_url="https://placehold.co/100x100", created_at=datetime.utcnow()),
]

fake_notifications = [
    Notification(id=1, message="alice te siguió", created_at=datetime.utcnow()),
    Notification(id=2, message="bob comentó tu post", created_at=datetime.utcnow()),
]

fake_comments = {
    1: [
        Comment(id=1, post_id=1, user="bob", content="Nice post!", created_at=datetime.utcnow()),
    ],
    2: []
}

# track users that liked each post
fake_likes = {
    1: {"bob"},
    2: set(),
}

# Simple chat and message storage
fake_chats = [
    Chat(id=1, participants=["alice", "bob"], created_at=datetime.utcnow()),
]

fake_messages = {
    1: [
        Message(
            id=1,
            chat_id=1,
            sender="alice",
            content="Hola Bob!",
            created_at=datetime.utcnow(),
        ),
        Message(
            id=2,
            chat_id=1,
            sender="bob",
            content="Hola Alice!",
            created_at=datetime.utcnow(),
        ),
    ]
}
