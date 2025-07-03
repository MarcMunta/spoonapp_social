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
    StoryBlock,
    StoryBlockCreate,
    Category,
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
    fake_story_blocks,
    fake_categories,
)


def _user_color(username: str) -> str | None:
    for u in fake_users:
        if u.username == username:
            return u.bubble_color
    return None


def _post_response(post: Post, liked: bool | None = None) -> Post:
    likes = len(fake_likes.get(post.id, set()))
    liked_val = (
        liked
        if liked is not None
        else False
    )
    return Post(
        **post.dict(),
        likes=likes,
        liked=liked_val,
        bubble_color=_user_color(post.user),
    )

app = FastAPI(title="SpoonApp API")

@app.get("/")
def read_root():
    return {"message": "SpoonApp API"}


@app.get("/posts", response_model=List[Post])
def list_posts(
    user: str | None = None,
    offset: int = 0,
    limit: int = 10,
    category: str | None = None,
):
    """Return sample list of posts with pagination."""
    posts: List[Post] = []
    posts_source = fake_posts
    if category:
        posts_source = [p for p in posts_source if category in p.categories]
    sliced = posts_source[offset : offset + limit]
    for p in sliced:
        liked = user in fake_likes.get(p.id, set()) if user else False
        posts.append(_post_response(p, liked))
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
        categories=data.categories,
        bubble_color=_user_color(data.user),
    )
    fake_posts.append(post)
    fake_likes[post.id] = set()
    return _post_response(post)


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


@app.post("/notifications/{nid}/read")
def mark_notification_read(nid: int):
    for i, n in enumerate(fake_notifications):
        if n.id == nid:
            fake_notifications[i] = n.copy(update={"is_read": True})
            return {"read": True}
    raise HTTPException(status_code=404, detail="Notification not found")


@app.get("/categories", response_model=List[Category])
def list_categories():
    return fake_categories


@app.get("/posts/{post_id}/comments", response_model=List[Comment])
def list_comments(post_id: int):
    comments = fake_comments.get(post_id, [])
    return [
        Comment(**c.dict(), bubble_color=_user_color(c.user)) for c in comments
    ]

@app.post("/posts/{post_id}/comments", response_model=Comment)
def add_comment(post_id: int, data: CommentRequest):
    comments = fake_comments.setdefault(post_id, [])
    comment = Comment(
        id=len(comments) + 1,
        post_id=post_id,
        user=data.user,
        content=data.content,
        created_at=datetime.utcnow(),
    )
    comments.append(comment)
    return Comment(**comment.dict(), bubble_color=_user_color(data.user))



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
    return _post_response(post, True)



@app.delete("/posts/{post_id}/likes", response_model=Post)
def unlike_post(post_id: int, data: LikeRequest):
    post = _get_post(post_id)
    likes = fake_likes.setdefault(post_id, set())
    likes.discard(data.user)
    post.likes = len(likes)
    return _post_response(post, False)



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
    user = User(username=data.username, password=data.password, bubble_color="#ff0000")
    fake_users.append(user)
    return {"token": "fake-token", "username": user.username}


@app.get("/users/{username}", response_model=UserProfile)
def get_user(username: str):
    for u in fake_users:
        if u.username == username:
            return UserProfile(
                username=u.username,
                bio=u.bio,
                avatar_url=u.avatar_url,
                bubble_color=u.bubble_color,
            )
    raise HTTPException(status_code=404, detail="User not found")


@app.put("/users/{username}", response_model=UserProfile)
def update_user(username: str, data: ProfileUpdate):
    for i, u in enumerate(fake_users):
        if u.username == username:
            updated = u.copy(update={
                "bio": data.bio if data.bio is not None else u.bio,
                "avatar_url": data.avatar_url if data.avatar_url is not None else u.avatar_url,
                "bubble_color": data.bubble_color if data.bubble_color is not None else u.bubble_color,
            })
            fake_users[i] = updated
            return UserProfile(
                username=updated.username,
                bio=updated.bio,
                avatar_url=updated.avatar_url,
                bubble_color=updated.bubble_color,
            )
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


@app.get("/story-blocks", response_model=List[StoryBlock])
def list_story_blocks(owner: str):
    """Return users from whom the owner hides their stories."""
    return [b for b in fake_story_blocks if b.story_owner == owner]


@app.post("/story-blocks", response_model=StoryBlock)
def create_story_block(data: StoryBlockCreate):
    block = StoryBlock(
        id=len(fake_story_blocks) + 1,
        story_owner=data.story_owner,
        hidden_user=data.hidden_user,
        created_at=datetime.utcnow(),
    )
    fake_story_blocks.append(block)
    return block


@app.post("/story-blocks/{username}/unhide")
def unhide_story(username: str, owner: str):
    for i, b in enumerate(fake_story_blocks):
        if b.story_owner == owner and b.hidden_user == username:
            fake_story_blocks.pop(i)
            return {"unhidden": True}
    raise HTTPException(status_code=404, detail="Block not found")


@app.get("/users", response_model=List[UserProfile])
def list_users(q: str | None = None):
    users = [UserProfile(username=u.username, bio=u.bio, avatar_url=u.avatar_url) for u in fake_users]
    if q:
        q_lower = q.lower()
        return [u for u in users if q_lower in u.username.lower()]
    return users

