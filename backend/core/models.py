from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
from django.utils.text import slugify
from django.utils.translation import gettext_lazy as _
from datetime import timedelta
import base64

class PostCategory(models.Model):
    name = models.CharField(max_length=100)
    slug = models.SlugField(max_length=100, blank=True, null=True)  # <-- permite nulo

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    CATEGORY_TRANSLATIONS = {
        "entrantes": _("Starters"),
        "primer-plato": _("First course"),
        "segundo-plato": _("Second course"),
        "postres": _("Desserts"),
        "clips": _("Clips"),
    }

    def __str__(self):
        if self.slug:
            translation = self.CATEGORY_TRANSLATIONS.get(self.slug, self.name)
            return str(translation)
        return str(self.name)

class Post(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    image = models.BinaryField(null=True, blank=True, editable=True)
    image_mime = models.CharField(max_length=100, null=True, blank=True)
    video = models.BinaryField(null=True, blank=True, editable=True)
    video_mime = models.CharField(max_length=100, null=True, blank=True)
    caption = models.TextField(blank=True)
    categories = models.ManyToManyField(PostCategory, related_name='posts')
    created_at = models.DateTimeField(auto_now_add=True)

    @property
    def image_data_url(self):
        if self.image and self.image_mime:
            return "data:%s;base64,%s" % (
                self.image_mime,
                base64.b64encode(self.image).decode(),
            )
        return ""

    @property
    def video_data_url(self):
        if self.video and self.video_mime:
            return "data:%s;base64,%s" % (
                self.video_mime,
                base64.b64encode(self.video).decode(),
            )
        return ""

    @property
    def is_video(self):
        return bool(self.video and self.video_mime)

class PostLike(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    post = models.ForeignKey(Post, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

class PostComment(models.Model):
    post = models.ForeignKey(Post, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    parent = models.ForeignKey(
        "self",
        null=True,
        blank=True,
        related_name="replies",
        on_delete=models.CASCADE,
    )
    content = models.TextField()
    likes = models.PositiveIntegerField(default=0)
    dislikes = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

class PostCommentLike(models.Model):
    comment = models.ForeignKey(PostComment, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

class PostShare(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    post = models.ForeignKey(Post, on_delete=models.CASCADE)
    shared_at = models.DateTimeField(auto_now_add=True)

class PostSave(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    post = models.ForeignKey(Post, on_delete=models.CASCADE)
    saved_at = models.DateTimeField(auto_now_add=True)

def default_expiration():
    return timezone.now() + timedelta(hours=24)


class Story(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    media_data = models.BinaryField(null=True, blank=True, editable=True)
    media_mime = models.CharField(max_length=100, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField(default=default_expiration)

    @property
    def is_video(self):
        return self.media_mime and self.media_mime.startswith('video')
    
    @property
    def media_data_url(self):
        if self.media_data and self.media_mime:
            return "data:%s;base64,%s" % (
                self.media_mime,
                base64.b64encode(self.media_data).decode(),
            )
        return ""

class StoryView(models.Model):
    story = models.ForeignKey(Story, on_delete=models.CASCADE)
    viewer = models.ForeignKey(User, on_delete=models.CASCADE)
    viewed_at = models.DateTimeField(auto_now_add=True)

class StoryLike(models.Model):
    story = models.ForeignKey(Story, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    liked_at = models.DateTimeField(auto_now_add=True)

class Chat(models.Model):
    participants = models.ManyToManyField(User, related_name='chats')
    created_at = models.DateTimeField(auto_now_add=True)
    last_message_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-last_message_at']
    
    def get_other_participant(self, user):
        return self.participants.exclude(id=user.id).first()
    
    def last_message(self):
        return self.messages.order_by('-sent_at').first()

class Notification(models.Model):
    NOTIFICATION_TYPES = [
        ('message', 'New Message'),
        ('friend_request', 'Friend Request'),
        ('friend_accepted', 'Friend Request Accepted'),
        ('community_post', 'Community Post'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    notification_type = models.CharField(max_length=20, choices=NOTIFICATION_TYPES)
    title = models.CharField(max_length=100)
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    related_user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True, related_name='related_notifications')
    related_chat = models.ForeignKey('Chat', on_delete=models.CASCADE, null=True, blank=True)
    target_url = models.CharField(max_length=200, null=True, blank=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.user.username} - {self.title}"

class Message(models.Model):
    chat = models.ForeignKey(Chat, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    content = models.TextField()
    story = models.ForeignKey(Story, null=True, blank=True, on_delete=models.SET_NULL)
    sent_at = models.DateTimeField(auto_now_add=True)
    read = models.BooleanField(default=False)

    class Meta:
        ordering = ['sent_at']
    
    def save(self, *args, **kwargs):
        is_new = self.pk is None
        super().save(*args, **kwargs)
        
        if is_new:
            # Create notification for other chat participants
            other_participants = self.chat.participants.exclude(id=self.sender.id)
            for participant in other_participants:
                Notification.objects.create(
                    user=participant,
                    notification_type='message',
                    title=f'New message from {self.sender.username}',
                    message=self.content[:50] + ('...' if len(self.content) > 50 else ''),
                    related_user=self.sender,
                    related_chat=self.chat
                )

class FriendRequest(models.Model):
    from_user = models.ForeignKey(User, related_name='sent_requests', on_delete=models.CASCADE)
    to_user = models.ForeignKey(User, related_name='received_requests', on_delete=models.CASCADE)
    timestamp = models.DateTimeField(auto_now_add=True)
    accepted = models.BooleanField(default=False)
    
    class Meta:
        unique_together = ('from_user', 'to_user')


class CommunityFollow(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    community = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='community_followers',
        limit_choices_to={'profile__account_type': 'community'},
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'community')

class Profile(models.Model):
    ACCOUNT_TYPES = [
        ("individual", "Individual"),
        ("community", "Comunidad"),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE)
    account_type = models.CharField(max_length=20, choices=ACCOUNT_TYPES, default="individual")
    email_notifications = models.BooleanField(default=True)
    push_notifications = models.BooleanField(default=True)
    profile_picture = models.BinaryField(null=True, blank=True, editable=True)
    profile_picture_mime = models.CharField(max_length=100, null=True, blank=True)
    last_seen = models.DateTimeField(auto_now=True)
    friends = models.ManyToManyField('self', symmetrical=False, blank=True)
    bio = models.TextField(blank=True, null=True)
    website = models.URLField(blank=True, null=True)
    location = models.CharField(max_length=100, blank=True, null=True)
    gender = models.CharField(max_length=20, blank=True, null=True)
    bubble_color = models.CharField(max_length=7, default="#ff0000")
    followers = models.PositiveIntegerField(default=0)

    def __str__(self):
        return self.user.username

    @property
    def online(self):
        from django.utils import timezone
        from datetime import timedelta
        return timezone.now() - self.last_seen < timedelta(minutes=5)

    @property
    def profile_picture_data_url(self):
        if self.profile_picture and self.profile_picture_mime:
            return "data:%s;base64,%s" % (
                self.profile_picture_mime,
                base64.b64encode(self.profile_picture).decode(),
            )
        return ""


class Block(models.Model):
    blocker = models.ForeignKey(User, on_delete=models.CASCADE, related_name='blocking')
    blocked = models.ForeignKey(User, on_delete=models.CASCADE, related_name='blocked_by')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('blocker', 'blocked')


class StoryVisibilityBlock(models.Model):
    story_owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='story_hidden_to')
    hidden_user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='hidden_story_from')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('story_owner', 'hidden_user')
