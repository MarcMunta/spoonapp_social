from django.utils import timezone
from .models import Profile

class UpdateLastSeenMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.user.is_authenticated:
            try:
                profile, created = Profile.objects.get_or_create(user=request.user)
                profile.last_seen = timezone.now()
                profile.save(update_fields=['last_seen'])
            except Exception:
                pass  # Silently handle any errors
        
        response = self.get_response(request)
        return response