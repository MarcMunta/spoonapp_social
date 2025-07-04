from fastapi import FastAPI, HTTPException, Response, Depends
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
from typing import List
from sqlalchemy.orm import Session

from models import (
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
from data import (
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
from database import (
    SessionLocal,
    init_db,
    UserDB,
    PostDB,
)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def _user_color(db: Session, username: str) -> str | None:
    user = db.query(UserDB).filter_by(username=username).first()
    return user.bubble_color if user else None


def _post_response(db_post: PostDB, liked: bool | None = None) -> Post:
    likes = len(fake_likes.get(db_post.id, set()))
    liked_val = liked if liked is not None else False
    return Post(
        id=db_post.id,
        user=db_post.user.username,
        caption=db_post.caption,
        created_at=db_post.created_at,
        image_url=db_post.image_url,
        likes=likes,
        liked=liked_val,
        categories=db_post.categories.split(",") if db_post.categories else [],
        bubble_color=db_post.user.bubble_color,
    )

app = FastAPI(title="SpoonApp API")

# CORS for Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Puedes restringir a ["http://localhost:55976"] si lo deseas
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def startup_event():
    init_db(fake_users=fake_users, fake_posts=fake_posts)

@app.get("/")
def read_root():
    return {"message": "SpoonApp API"}


@app.get("/posts", response_model=List[Post])
def list_posts(
    user: str | None = None,
    offset: int = 0,
    limit: int = 10,
    category: str | None = None,
    db: Session = Depends(get_db),
):
    """Return list of posts from the database with pagination."""
    query = db.query(PostDB)
    if category:
        query = query.filter(PostDB.categories.like(f"%{category}%"))
    if user:
        query = query.join(UserDB).filter(UserDB.username == user)
    posts_db = query.order_by(PostDB.id).offset(offset).limit(limit).all()
    posts: List[Post] = []
    for p in posts_db:
        liked = user in fake_likes.get(p.id, set()) if user else False
        posts.append(_post_response(p, liked))
    return posts


@app.post("/posts", response_model=Post)
def create_post(data: PostRequest, db: Session = Depends(get_db)):
    user_obj = db.query(UserDB).filter_by(username=data.user).first()
    if not user_obj:
        raise HTTPException(status_code=404, detail="User not found")
    post = PostDB(
        user_id=user_obj.id,
        caption=data.caption,
        created_at=datetime.utcnow(),
        image_url=data.image_url,
        categories=",".join(data.categories),
    )
    db.add(post)
    db.commit()
    db.refresh(post)
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
def list_comments(post_id: int, db: Session = Depends(get_db)):
    comments = fake_comments.get(post_id, [])
    return [
        Comment(**c.dict(), bubble_color=_user_color(db, c.user)) for c in comments
    ]

@app.post("/posts/{post_id}/comments", response_model=Comment)
def add_comment(post_id: int, data: CommentRequest, db: Session = Depends(get_db)):
    comments = fake_comments.setdefault(post_id, [])
    comment = Comment(
        id=len(comments) + 1,
        post_id=post_id,
        user=data.user,
        content=data.content,
        created_at=datetime.utcnow(),
    )
    comments.append(comment)
    return Comment(**comment.dict(), bubble_color=_user_color(db, data.user))


def _get_post(db: Session, post_id: int) -> PostDB:
    post = db.query(PostDB).filter_by(id=post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    return post


@app.post("/posts/{post_id}/likes", response_model=Post)
def like_post(post_id: int, data: LikeRequest, db: Session = Depends(get_db)):
    post = _get_post(db, post_id)
    likes = fake_likes.setdefault(post_id, set())
    likes.add(data.user)
    post.likes = len(likes)
    db.commit()
    return _post_response(post, True)


@app.delete("/posts/{post_id}/likes", response_model=Post)
def unlike_post(post_id: int, data: LikeRequest, db: Session = Depends(get_db)):
    post = _get_post(db, post_id)
    likes = fake_likes.setdefault(post_id, set())
    likes.discard(data.user)
    post.likes = len(likes)
    db.commit()
    return _post_response(post, False)


@app.delete("/posts/{post_id}")
def delete_post(post_id: int, user: str, db: Session = Depends(get_db)):
    """Delete a post if the requester is the author."""
    post = _get_post(db, post_id)
    if post.user.username != user:
        raise HTTPException(status_code=403, detail="Forbidden")
    db.delete(post)
    db.commit()
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
def login(data: LoginRequest, db: Session = Depends(get_db)):
    """Simple login endpoint that validates against stored users."""
    user = db.query(UserDB).filter_by(username=data.username).first()
    if user and user.password == data.password:
        return {"token": "fake-token", "username": user.username}
    raise HTTPException(status_code=400, detail="Invalid credentials")


@app.post("/signup")
def signup(data: LoginRequest, db: Session = Depends(get_db)):
    """Create a new user if the username is free."""
    if db.query(UserDB).filter_by(username=data.username).first():
        raise HTTPException(status_code=400, detail="Username taken")
    user = UserDB(username=data.username, password=data.password, bubble_color="#ff0000")
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"token": "fake-token", "username": user.username}


@app.get("/users/{username}", response_model=UserProfile)
def get_user(username: str, db: Session = Depends(get_db)):
    u = db.query(UserDB).filter_by(username=username).first()
    if not u:
        raise HTTPException(status_code=404, detail="User not found")
    return UserProfile(
        username=u.username,
        bio=u.bio,
        avatar_url=u.avatar_url,
        bubble_color=u.bubble_color,
    )


@app.put("/users/{username}", response_model=UserProfile)
def update_user(username: str, data: ProfileUpdate, db: Session = Depends(get_db)):
    u = db.query(UserDB).filter_by(username=username).first()
    if not u:
        raise HTTPException(status_code=404, detail="User not found")
    if data.bio is not None:
        u.bio = data.bio
    if data.avatar_url is not None:
        u.avatar_url = data.avatar_url
    if data.bubble_color is not None:
        u.bubble_color = data.bubble_color
    db.commit()
    db.refresh(u)
    return UserProfile(
        username=u.username,
        bio=u.bio,
        avatar_url=u.avatar_url,
        bubble_color=u.bubble_color,
    )


@app.get("/chats", response_model=List[Chat])
def list_chats(user: str | None = None):
    if user:
        return [c for c in fake_chats if user in c.participants]
    return fake_chats


@app.get("/chats/{chat_id}/messages", response_model=List[Message])
def get_messages(chat_id: int, db: Session = Depends(get_db)):
    messages = fake_messages.get(chat_id, [])
    return [
        Message(**m.dict(), bubble_color=_user_color(db, m.sender)) for m in messages
    ]


@app.post("/chats/{chat_id}/messages", response_model=Message)
def add_message(chat_id: int, data: MessageRequest, db: Session = Depends(get_db)):
    messages = fake_messages.setdefault(chat_id, [])
    msg = Message(
        id=len(messages) + 1,
        chat_id=chat_id,
        sender=data.sender,
        content=data.content,
        created_at=datetime.utcnow(),
        bubble_color=_user_color(db, data.sender),
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
def list_users(q: str | None = None, db: Session = Depends(get_db)):
    query = db.query(UserDB)
    if q:
        q_lower = f"%{q.lower()}%"
        query = query.filter(UserDB.username.ilike(q_lower))
    users = query.all()
    return [
        UserProfile(username=u.username, bio=u.bio, avatar_url=u.avatar_url, bubble_color=u.bubble_color)
        for u in users
    ]

