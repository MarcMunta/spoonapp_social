from django.contrib.auth.models import User
from .models import FriendRequest, Notification
from django.db.models import Q


def friend_requests_processor(request):
    context = {}
    if request.user.is_authenticated:
        requests = FriendRequest.objects.filter(to_user=request.user, accepted=False)
        all_users = User.objects.exclude(id=request.user.id)
        
        # Add notifications - ordered by created_at descending
        unread_notifications = Notification.objects.filter(
            user=request.user, 
            is_read=False
        ).order_by('-created_at')
        notification_count = unread_notifications.count()

        friend_status_list = []
        for user in all_users:
            sent = FriendRequest.objects.filter(from_user=request.user, to_user=user, accepted=False).exists()
            received = FriendRequest.objects.filter(from_user=user, to_user=request.user, accepted=False).exists()
            friends = FriendRequest.objects.filter(
                ((Q(from_user=request.user) & Q(to_user=user)) |
                (Q(from_user=user) & Q(to_user=request.user))) & Q(accepted=True)
            ).exists()
            friend_status_list.append({
                "id": user.id,
                "username": user.username,
                "status": (
                    "friends" if friends else
                    "request_sent" if sent else
                    "request_received" if received else
                    "none"
                )
            })

        context = {
            'pending_requests': requests,
            'all_users': friend_status_list,
            'unread_notifications': unread_notifications,
            'notification_count': notification_count
        }
    return context
