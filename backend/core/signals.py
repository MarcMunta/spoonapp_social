from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth.models import User
from .models import Profile
from .default_avatar import DEFAULT_AVATAR_BYTES

@receiver(post_save, sender=User)
def ensure_profile(sender, instance, created, **kwargs):
    profile, _ = Profile.objects.get_or_create(user=instance)
    if created or not profile.profile_picture:
        profile.profile_picture = DEFAULT_AVATAR_BYTES
        profile.profile_picture_mime = 'image/png'
        profile.save()
