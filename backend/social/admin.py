from django.contrib import admin
from .models import Post, PostCategory, PostLike, PostComment, PostSave, Story, StoryView, StoryLike, Follow, Message, Profile

admin.site.register(Post)
admin.site.register(PostCategory)
admin.site.register(PostLike)
admin.site.register(PostComment)
admin.site.register(PostSave)
admin.site.register(Story)
admin.site.register(StoryView)
admin.site.register(StoryLike)
admin.site.register(Follow)
admin.site.register(Message)
admin.site.register(Profile)
