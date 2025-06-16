from django.contrib.auth.models import User
from .models import FriendRequest

def friend_requests_processor(request):
    context = {}
    if request.user.is_authenticated:
        requests = FriendRequest.objects.filter(to_user=request.user, accepted=False)
        users = User.objects.exclude(id=request.user.id)
        context = {
            'pending_requests': requests,
            'all_users': users
        }
    return context