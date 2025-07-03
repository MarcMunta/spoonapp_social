from datetime import datetime
from .models import (
    Post,
    Story,
    User,
    Notification,
    Comment,
    Chat,
    Message,
    FriendRequest,
    Block,
    StoryBlock,
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
] + [
    Post(
        id=i,
        user="alice" if i % 2 else "bob",
        caption=f"Extra Post {i}",
        created_at=datetime.utcnow(),
        image_url="https://placehold.co/600x400",
        likes=0,
    )
    for i in range(3, 21)
]

fake_users = [
    User(
        username="alice",
        password="password",
        bio="Me encanta cocinar",
        avatar_url="https://placehold.co/64x64",
    ),
    User(
        username="bob",
        password="password",
        bio="Amante de la comida",
        avatar_url="https://placehold.co/64x64",
    ),
    User(
        username="carol",
        password="password",
        bio="Fotógrafa de comida",
        avatar_url="https://placehold.co/64x64",
    ),
    User(
        username="dave",
        password="password",
        bio="Chef profesional",
        avatar_url="https://placehold.co/64x64",
    ),
]

fake_stories = [
    Story(id=1, user="alice", image_url="https://placehold.co/100x100", created_at=datetime.utcnow()),
    Story(id=2, user="bob", image_url="https://placehold.co/100x100", created_at=datetime.utcnow()),
    Story(id=3, user="alice", image_url="https://placehold.co/100x100", created_at=datetime.utcnow()),
    Story(id=4, user="carol", image_url="https://placehold.co/100x100", created_at=datetime.utcnow()),
    Story(id=5, user="dave", image_url="https://placehold.co/100x100", created_at=datetime.utcnow()),
]

fake_notifications = [
    Notification(
        id=1,
        message="alice te siguió",
        created_at=datetime.utcnow(),
        title="Nuevo seguidor",
        notification_type="friend_request",
    ),
    Notification(
        id=2,
        message="bob comentó tu post",
        created_at=datetime.utcnow(),
        title="Nuevo comentario",
        notification_type="comment",
    ),
]

fake_comments = {
    1: [
        Comment(id=1, post_id=1, user="bob", content="Nice post!", created_at=datetime.utcnow()),
    ],
    2: []
}
fake_comments.update({i: [] for i in range(3, 21)})

# track users that liked each post
fake_likes = {
    1: {"bob"},
    2: set(),
}
fake_likes.update({i: set() for i in range(3, 21)})

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

# Simple friend request storage
fake_friend_requests: list[FriendRequest] = [
    FriendRequest(
        id=1,
        from_user="bob",
        to_user="alice",
        created_at=datetime.utcnow(),
    )
]

# Blocked users storage
fake_blocks: list[Block] = [
    Block(
        id=1,
        blocker="alice",
        blocked="bob",
        created_at=datetime.utcnow(),
    )
]

# Story visibility blocks
fake_story_blocks: list[StoryBlock] = []
