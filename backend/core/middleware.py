from django.utils import timezone
from .models import Profile
from .default_avatar import DEFAULT_AVATAR_BYTES
from django.http import HttpResponseNotFound, HttpResponseForbidden, HttpResponseServerError
from django.shortcuts import redirect

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

class RedirectErrorMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        try:
            response = self.get_response(request)

            # Avoid redirect loops when already on an error page
            if request.path not in ['/404/', '/403/', '/500/']:
                if isinstance(response, HttpResponseNotFound):
                    return redirect('/404/')
                elif isinstance(response, HttpResponseForbidden):
                    return redirect('/403/')
                elif isinstance(response, HttpResponseServerError):
                    return redirect('/500/')

            return response

        except Exception:
            return redirect('/500/')  # Fallback si hay una excepción inesperada

class AutoLanguageMiddleware:
    """Set language based on the user's browser settings if not chosen yet."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        from django.utils import translation
        try:
            from django.utils.translation import LANGUAGE_SESSION_KEY
        except ImportError:  # Django >=4 removed LANGUAGE_SESSION_KEY constant
            LANGUAGE_SESSION_KEY = "django_language"
        from django.utils.translation import get_language_from_request

        if not request.session.get(LANGUAGE_SESSION_KEY):
            if request.get_host().startswith("192.168.0.118:300"):
                lang = "es"
            else:
                lang = get_language_from_request(request, check_path=False)
            request.session[LANGUAGE_SESSION_KEY] = lang
            translation.activate(lang)
            request.LANGUAGE_CODE = translation.get_language()

        response = self.get_response(request)
        return response
