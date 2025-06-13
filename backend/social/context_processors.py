from .models import FriendRequest

def friend_requests_processor(request):
    if request.user.is_authenticated:
        requests = FriendRequest.objects.filter(to_user=request.user, accepted=False)
        return {'pending_requests': requests}
    return {}
