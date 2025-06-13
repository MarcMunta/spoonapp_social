from django import forms
from .models import Post, PostComment

class PostForm(forms.ModelForm):
    class Meta:
        model = Post
        fields = ['image', 'caption', 'categories']

class CommentForm(forms.ModelForm):
    class Meta:
        model = PostComment
        fields = ['content']
