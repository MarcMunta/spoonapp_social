from django import forms
from django.db.models import Case, When, IntegerField
from django.utils.translation import gettext_lazy as _
from .models import Post, PostComment, Profile, PostCategory, Story
from django.contrib.auth.models import User

class PostForm(forms.ModelForm):
    image = forms.ImageField(required=False, widget=forms.ClearableFileInput(attrs={'class': 'file-input'}))

    class Meta:
        model = Post
        fields = ['image', 'caption', 'categories']
        widgets = {
            'caption': forms.Textarea(attrs={
                'rows': 3,
                'placeholder': _('What\'s on your spoon?'),
                'class': 'caption-input'
            }),
            'categories': forms.SelectMultiple(attrs={'class': 'category-select'}),
        }

    def save(self, commit=True):
        instance = super().save(commit=False)
        img = self.cleaned_data.get('image')
        if img and hasattr(img, "read"):
            instance.image = img.read()
            instance.image_mime = img.content_type
        if commit:
            instance.save()
            self.save_m2m()
        return instance

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        order = ['Entrantes', 'Primer plato', 'Segundo plato', 'Postres']
        when_statements = [When(name=name, then=idx) for idx, name in enumerate(order)]
        queryset = PostCategory.objects.annotate(
            order_priority=Case(*when_statements, default=len(order), output_field=IntegerField())
        ).order_by('order_priority', 'name').exclude(slug__isnull=True)
        self.fields['categories'].queryset = queryset

    def clean_categories(self):
        categories = self.cleaned_data['categories']
        primary_types = {'entrantes', 'primer plato', 'segundo plato', 'postres'}
        selected_primary = [c.name.lower() for c in categories if c.name.lower() in primary_types]
        if len(selected_primary) > 1:
            raise forms.ValidationError(
                _('You can only select one main type: first course, second course or desserts.')
            )
        return categories

class CommentForm(forms.ModelForm):
    class Meta:
        model = PostComment
        fields = ['content']
        widgets = {
            'content': forms.TextInput(attrs={
                'class': 'comment-input',
                'placeholder': _('Comment'),
            })
        }

class UserForm(forms.ModelForm):
    class Meta:
        model  = User
        fields = ["username", "first_name", "last_name", "email"]
        widgets = {
            "username":   forms.TextInput(attrs={"class": "form-control"}),
            "first_name": forms.TextInput(attrs={"class": "form-control"}),
            "last_name":  forms.TextInput(attrs={"class": "form-control"}),
            "email":      forms.EmailInput(attrs={"class": "form-control"}),
        }
        
class PrivacySettingsForm(forms.ModelForm):
    class Meta:
        model  = Profile
        fields = ["is_private", "email_notifications", "push_notifications"]
        widgets = {f: forms.CheckboxInput() for f in fields}


class ProfileForm(forms.ModelForm):
    profile_picture = forms.ImageField(required=False)
    COLOR_CHOICES = [
        ("#ff0000", "Red"),
        ("#ffa500", "Orange"),
        ("#ffff00", "Yellow"),
        ("#008000", "Green"),
        ("#00ffff", "Cyan"),
        ("#0000ff", "Blue"),
        ("#800080", "Purple"),
        ("#ff00ff", "Magenta"),
        ("#ffc0cb", "Pink"),
        ("#a52a2a", "Brown"),
    ]
    bubble_color = forms.ChoiceField(choices=COLOR_CHOICES, required=False)

    class Meta:
        model = Profile
        fields = ['bio', 'website', 'location', 'gender', 'bubble_color']
        widgets = {
            'bio': forms.Textarea(attrs={'rows': 3, 'placeholder': _('Tell us about yourself...')}),
            'website': forms.URLInput(attrs={'placeholder': 'https://'}),
            'location': forms.TextInput(attrs={'placeholder': _('Your city')}),
            'gender': forms.Select(choices=[('', _('Select')), ('Hombre', _('Male')), ('Mujer', _('Female')), ('Otro', _('Other'))])
        }

    def save(self, commit=True):
        instance = super().save(commit=False)
        pic = self.cleaned_data.get('profile_picture')
        color = self.cleaned_data.get('bubble_color')
        if pic and hasattr(pic, "read"):
            instance.profile_picture = pic.read()
            instance.profile_picture_mime = pic.content_type
        if color:
            instance.bubble_color = color
        if commit:
            instance.save()
        return instance

class StoryForm(forms.ModelForm):
    media_file = forms.FileField(required=False, widget=forms.ClearableFileInput(attrs={
        'accept': 'image/*,video/*',
        'hidden': True,
    }))

    class Meta:
        model = Story
        fields = ['media_file']

    def save(self, commit=True):
        instance = super().save(commit=False)
        media = self.cleaned_data.get('media_file')
        if media and hasattr(media, "read"):
            instance.media_data = media.read()
            instance.media_mime = media.content_type
        if commit:
            instance.save()
        return instance
