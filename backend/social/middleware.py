from django.utils import timezone

class UpdateLastSeenMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.user.is_authenticated:
            profile = request.user.profile  # o directamente user si lo guardas ahí
            profile.last_seen = timezone.now()
            profile.save(update_fields=["last_seen"])
        return self.get_response(request)