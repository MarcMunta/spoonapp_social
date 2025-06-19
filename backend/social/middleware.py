from django.utils import timezone
from .models import Profile
from .default_avatar import DEFAULT_AVATAR_BYTES
from django.shortcuts import redirect
from django.http import HttpResponseNotFound

class UpdateLastSeenMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.user.is_authenticated:
            try:
                profile, created = Profile.objects.get_or_create(user=request.user)
                if created or not profile.profile_picture:
                    profile.profile_picture = DEFAULT_AVATAR_BYTES
                    profile.profile_picture_mime = 'image/png'
                profile.last_seen = timezone.now()
                profile.save()
            except Exception:
                pass  # Silently handle any errors
        
        response = self.get_response(request)
        return response

class Redirect404Middleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)

        if isinstance(response, HttpResponseNotFound):
            return redirect('/404/')  # redirige al endpoint manual

        return response
