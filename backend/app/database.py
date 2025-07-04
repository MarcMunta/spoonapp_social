from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import declarative_base, sessionmaker, relationship

DATABASE_URL = "sqlite:///./app.db"

engine = create_engine(
    DATABASE_URL, connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)

Base = declarative_base()

class UserDB(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    password = Column(String)
    bio = Column(String, nullable=True)
    avatar_url = Column(String, nullable=True)
    bubble_color = Column(String, nullable=True)
    posts = relationship("PostDB", back_populates="user")

class PostDB(Base):
    __tablename__ = "posts"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    caption = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
    image_url = Column(String, nullable=True)
    likes = Column(Integer, default=0)
    categories = Column(String, nullable=True)
    user = relationship("UserDB", back_populates="posts")


def init_db(fake_users=None, fake_posts=None):
    Base.metadata.create_all(bind=engine)
    if fake_users is None:
        return
    db = SessionLocal()
    if db.query(UserDB).first():
        db.close()
        return
    for u in fake_users:
        user = UserDB(
            username=u.username,
            password=u.password,
            bio=getattr(u, "bio", None),
            avatar_url=getattr(u, "avatar_url", None),
            bubble_color=getattr(u, "bubble_color", None),
        )
        db.add(user)
    db.commit()
    if fake_posts:
        for p in fake_posts:
            user = db.query(UserDB).filter_by(username=p.user).first()
            post = PostDB(
                id=p.id,
                user_id=user.id if user else None,
                caption=p.caption,
                created_at=p.created_at,
                image_url=p.image_url,
                likes=p.likes,
                categories=",".join(p.categories) if getattr(p, "categories", None) else None,
            )
            db.add(post)
        db.commit()
    db.close()
