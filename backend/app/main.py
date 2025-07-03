from fastapi import FastAPI, HTTPException
from datetime import datetime
from typing import List

from .models import (
    Post,
    Story,
    Notification,
    LoginRequest,
    User,
    Comment,
    CommentRequest,
    LikeRequest,
    PostRequest,
    Chat,
    Message,
    MessageRequest,
    UserProfile,
    ProfileUpdate,
)
from .data import (
    fake_posts,
    fake_stories,
    fake_notifications,
    fake_users,
    fake_comments,
    fake_likes,
    fake_chats,
    fake_messages,
)

app = FastAPI(title="SpoonApp API")

@app.get("/")
def read_root():
    return {"message": "SpoonApp API"}


@app.get("/posts", response_model=List[Post])
def list_posts(user: str | None = None):
    """Return sample list of posts."""
    posts: List[Post] = []
    for p in fake_posts:
        likes = len(fake_likes.get(p.id, set()))
        liked = user in fake_likes.get(p.id, set()) if user else False
        posts.append(Post(**p.dict(), likes=likes, liked=liked))
    return posts


@app.post("/posts", response_model=Post)
def create_post(data: PostRequest):
    post = Post(
        id=len(fake_posts) + 1,
        user=data.user,
        caption=data.caption,
        created_at=datetime.utcnow(),
        image_url=data.image_url,
        likes=0,
    )
    fake_posts.append(post)
    fake_likes[post.id] = set()
    return post


@app.get("/stories", response_model=List[Story])
def list_stories():
    """Return sample list of stories."""
    return fake_stories


@app.get("/notifications", response_model=List[Notification])
def list_notifications():
    """Return sample list of notifications."""
    return fake_notifications


@app.get("/posts/{post_id}/comments", response_model=List[Comment])
def list_comments(post_id: int):
    return fake_comments.get(post_id, [])

@app.post("/posts/{post_id}/comments", response_model=Comment)
def add_comment(post_id: int, data: CommentRequest):
    comments = fake_comments.setdefault(post_id, [])
    comment = Comment(id=len(comments)+1, post_id=post_id, user=data.user, content=data.content, created_at=datetime.utcnow())
    comments.append(comment)
    return comment


def _get_post(post_id: int) -> Post:
    for p in fake_posts:
        if p.id == post_id:
            return p
    raise HTTPException(status_code=404, detail="Post not found")


@app.post("/posts/{post_id}/likes", response_model=Post)
def like_post(post_id: int, data: LikeRequest):
    post = _get_post(post_id)
    likes = fake_likes.setdefault(post_id, set())
    likes.add(data.user)
    post.likes = len(likes)
    return Post(**post.dict(), likes=post.likes, liked=True)


@app.delete("/posts/{post_id}/likes", response_model=Post)
def unlike_post(post_id: int, data: LikeRequest):
    post = _get_post(post_id)
    likes = fake_likes.setdefault(post_id, set())
    likes.discard(data.user)
    post.likes = len(likes)
    return Post(**post.dict(), likes=post.likes, liked=False)


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


@app.get("/users/{username}", response_model=UserProfile)
def get_user(username: str):
    for u in fake_users:
        if u.username == username:
            return UserProfile(username=u.username, bio=u.bio, avatar_url=u.avatar_url)
    raise HTTPException(status_code=404, detail="User not found")


@app.put("/users/{username}", response_model=UserProfile)
def update_user(username: str, data: ProfileUpdate):
    for i, u in enumerate(fake_users):
        if u.username == username:
            updated = u.copy(update={
                "bio": data.bio if data.bio is not None else u.bio,
                "avatar_url": data.avatar_url if data.avatar_url is not None else u.avatar_url,
            })
            fake_users[i] = updated
            return UserProfile(username=updated.username, bio=updated.bio, avatar_url=updated.avatar_url)
    raise HTTPException(status_code=404, detail="User not found")


@app.get("/chats", response_model=List[Chat])
def list_chats(user: str | None = None):
    if user:
        return [c for c in fake_chats if user in c.participants]
    return fake_chats


@app.get("/chats/{chat_id}/messages", response_model=List[Message])
def get_messages(chat_id: int):
    return fake_messages.get(chat_id, [])


@app.post("/chats/{chat_id}/messages", response_model=Message)
def add_message(chat_id: int, data: MessageRequest):
    messages = fake_messages.setdefault(chat_id, [])
    msg = Message(
        id=len(messages) + 1,
        chat_id=chat_id,
        sender=data.sender,
        content=data.content,
        created_at=datetime.utcnow(),
    )
    messages.append(msg)
    return msg
