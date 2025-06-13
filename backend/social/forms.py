from django import forms
from django.db.models import Case, When, IntegerField
from .models import Post, PostComment, Profile, PostCategory

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

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        order = ['Entrantes', 'Primer plato', 'Segundo plato', 'Postres']
        when_statements = [When(name=name, then=idx) for idx, name in enumerate(order)]
        queryset = PostCategory.objects.annotate(
            order_priority=Case(*when_statements, default=len(order), output_field=IntegerField())
        ).order_by('order_priority', 'name')
        self.fields['categories'].queryset = queryset

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
