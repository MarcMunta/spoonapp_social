from django import forms
from .models import Post, PostComment, Profile

class PostForm(forms.ModelForm):
    class Meta:
        model = Post
        fields = ['image', 'caption', 'categories']
        widgets = {
            'image': forms.ClearableFileInput(attrs={'class': 'file-input'}),
            'caption': forms.Textarea(attrs={
                'rows': 3,
                'placeholder': '¿Qué tienes en tu cuchara?',
                'class': 'caption-input'
            }),
            'categories': forms.SelectMultiple(attrs={'class': 'category-select'}),
        }

class CommentForm(forms.ModelForm):
    class Meta:
        model = PostComment
        fields = ['content']


class ProfileForm(forms.ModelForm):
    class Meta:
        model = Profile
        fields = ['profile_picture']
