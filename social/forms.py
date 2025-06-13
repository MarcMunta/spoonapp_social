from django import forms
from .models import Post, PostComment, Profile

class PostForm(forms.ModelForm):
    class Meta:
        model = Post
        fields = ['image', 'caption', 'categories']

class CommentForm(forms.ModelForm):
    class Meta:
        model = PostComment
        fields = ['content']


class ProfileForm(forms.ModelForm):
    class Meta:
        model = Profile
        fields = ['profile_picture']
