from django.contrib import admin
from .models import (
    Post,
    PostCategory,
    PostLike,
    PostComment,
    PostSave,
    Story,
    StoryView,
    StoryLike,
    Message,
    Profile,
)
from .forms import ProfileForm

admin.site.register(Post)
admin.site.register(PostCategory)
admin.site.register(PostLike)
admin.site.register(PostComment)
admin.site.register(PostSave)
admin.site.register(Story)
admin.site.register(StoryView)
admin.site.register(StoryLike)
admin.site.register(Message)


@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    form = ProfileForm
    list_display = (
        "user",
        "account_type",
        "email_notifications",
        "push_notifications",
    )
