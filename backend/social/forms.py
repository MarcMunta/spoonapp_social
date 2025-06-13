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

    def clean_categories(self):
        categories = self.cleaned_data['categories']
        primary_types = {'entrantes', 'primer plato', 'segundo plato', 'postres'}
        selected_primary = [c.name.lower() for c in categories if c.name.lower() in primary_types]
        if len(selected_primary) > 1:
            raise forms.ValidationError(
                'Solo puede elegir un tipo principal: primer plato, segundo plato o postres.'
            )
        return categories

class CommentForm(forms.ModelForm):
    class Meta:
        model = PostComment
        fields = ['content']
        widgets = {
            'content': forms.TextInput(attrs={
                'class': 'comment-input',
                'placeholder': 'Comentario',
            })
        }


class ProfileForm(forms.ModelForm):
    class Meta:
        model = Profile
        fields = ['profile_picture']
