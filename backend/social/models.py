from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
from django.utils.text import slugify
from datetime import timedelta

class PostCategory(models.Model):
    name = models.CharField(max_length=100)
    slug = models.SlugField(max_length=100, blank=True, null=True)  # <-- permite nulo

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

class Post(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    image = models.ImageField(upload_to='posts/')
    caption = models.TextField(blank=True)
    categories = models.ManyToManyField(PostCategory, related_name='posts')
    created_at = models.DateTimeField(auto_now_add=True)

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
    media_file = models.FileField(upload_to='stories/')
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField(default=default_expiration)

class StoryView(models.Model):
    story = models.ForeignKey(Story, on_delete=models.CASCADE)
    viewer = models.ForeignKey(User, on_delete=models.CASCADE)
    viewed_at = models.DateTimeField(auto_now_add=True)

class StoryLike(models.Model):
    story = models.ForeignKey(Story, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    liked_at = models.DateTimeField(auto_now_add=True)

class Follow(models.Model):
    follower = models.ForeignKey(User, on_delete=models.CASCADE, related_name='following')
    followed = models.ForeignKey(User, on_delete=models.CASCADE, related_name='followers')
    followed_at = models.DateTimeField(auto_now_add=True)

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
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    notification_type = models.CharField(max_length=20, choices=NOTIFICATION_TYPES)
    title = models.CharField(max_length=100)
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    related_user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True, related_name='related_notifications')
    related_chat = models.ForeignKey('Chat', on_delete=models.CASCADE, null=True, blank=True)
    
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

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    is_private = models.BooleanField(default=False)
    profile_picture = models.ImageField(upload_to='profile_pictures/', null=True, blank=True)
    last_seen = models.DateTimeField(auto_now=True)
    friends = models.ManyToManyField('self', symmetrical=False, blank=True)
    bio = models.TextField(blank=True, null=True)
    website = models.URLField(blank=True, null=True)
    location = models.CharField(max_length=100, blank=True, null=True)
    gender = models.CharField(max_length=20, blank=True, null=True)

    def __str__(self):
        return self.user.username
    
    @property
    def online(self):
        from django.utils import timezone
        from datetime import timedelta
        return timezone.now() - self.last_seen < timedelta(minutes=5)
