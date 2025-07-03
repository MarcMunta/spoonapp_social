from fastapi import FastAPI, HTTPException, Response
from datetime import datetime
from typing import List

from .models import (
    Post,
    Story,
    StoryCreate,
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
    FriendRequest,
    FriendRequestCreate,
    Block,
    BlockCreate,
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
    fake_friend_requests,
    fake_blocks,
)

app = FastAPI(title="SpoonApp API")

@app.get("/")
def read_root():
    return {"message": "SpoonApp API"}


@app.get("/posts", response_model=List[Post])
def list_posts(user: str | None = None, offset: int = 0, limit: int = 10):
    """Return sample list of posts with pagination."""
    posts: List[Post] = []
    sliced = fake_posts[offset : offset + limit]
    for p in sliced:
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
def list_stories(user: str | None = None):
    """Return sample list of stories."""
    if user:
        return [s for s in fake_stories if s.user == user]
    return fake_stories


@app.post("/stories", response_model=Story)
def create_story(data: StoryCreate):
    story = Story(
        id=len(fake_stories) + 1,
        user=data.user,
        image_url=data.image_url,
        created_at=datetime.utcnow(),
    )
    fake_stories.append(story)
    return story


@app.delete("/stories/{story_id}")
def delete_story(story_id: int, user: str):
    for i, s in enumerate(fake_stories):
        if s.id == story_id:
            if s.user != user:
                raise HTTPException(status_code=403, detail="Forbidden")
            fake_stories.pop(i)
            return Response(status_code=204)
    raise HTTPException(status_code=404, detail="Story not found")

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


@app.delete("/posts/{post_id}")
def delete_post(post_id: int, user: str):
    """Delete a post if the requester is the author."""
    post = _get_post(post_id)
    if post.user != user:
        raise HTTPException(status_code=403, detail="Forbidden")
    for i, p in enumerate(fake_posts):
        if p.id == post_id:
            fake_posts.pop(i)
            break
    fake_comments.pop(post_id, None)
    fake_likes.pop(post_id, None)
    return Response(status_code=204)


@app.delete("/posts/{post_id}/comments/{comment_id}")
def delete_comment(post_id: int, comment_id: int, user: str):
    """Delete a comment if the requester is the author."""
    comments = fake_comments.get(post_id, [])
    for i, c in enumerate(comments):
        if c.id == comment_id:
            if c.user != user:
                raise HTTPException(status_code=403, detail="Forbidden")
            comments.pop(i)
            return Response(status_code=204)
    raise HTTPException(status_code=404, detail="Comment not found")


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


@app.get("/friend-requests", response_model=List[FriendRequest])
def list_friend_requests(user: str | None = None):
    if user:
        return [fr for fr in fake_friend_requests if fr.to_user == user]
    return fake_friend_requests


@app.post("/friend-requests", response_model=FriendRequest)
def create_friend_request(data: FriendRequestCreate):
    fr = FriendRequest(
        id=len(fake_friend_requests) + 1,
        from_user=data.from_user,
        to_user=data.to_user,
        created_at=datetime.utcnow(),
    )
    fake_friend_requests.append(fr)
    return fr


@app.post("/friend-requests/{fr_id}/accept")
def accept_friend_request(fr_id: int):
    for i, fr in enumerate(fake_friend_requests):
        if fr.id == fr_id:
            fake_friend_requests.pop(i)
            return {"accepted": True}
    raise HTTPException(status_code=404, detail="Request not found")


@app.get("/blocks", response_model=List[Block])
def list_blocks(blocker: str):
    return [b for b in fake_blocks if b.blocker == blocker]


@app.post("/blocks", response_model=Block)
def block_user(data: BlockCreate):
    block = Block(
        id=len(fake_blocks) + 1,
        blocker=data.blocker,
        blocked=data.blocked,
        created_at=datetime.utcnow(),
    )
    fake_blocks.append(block)
    return block


@app.post("/blocks/{username}/unblock")
def unblock_user(username: str, blocker: str):
    for i, b in enumerate(fake_blocks):
        if b.blocker == blocker and b.blocked == username:
            fake_blocks.pop(i)
            return {"unblocked": True}
    raise HTTPException(status_code=404, detail="Block not found")


@app.get("/users", response_model=List[UserProfile])
def list_users(q: str | None = None):
    users = [UserProfile(username=u.username, bio=u.bio, avatar_url=u.avatar_url) for u in fake_users]
    if q:
        q_lower = q.lower()
        return [u for u in users if q_lower in u.username.lower()]
    return users

