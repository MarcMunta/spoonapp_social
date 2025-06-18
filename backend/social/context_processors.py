from django.contrib.auth.models import User
from .models import FriendRequest, Notification
from django.db.models import Q

def get_friends(user):
    """Helper function to get friends list"""
    sent = FriendRequest.objects.filter(from_user=user, accepted=True).values_list('to_user', flat=True)
    received = FriendRequest.objects.filter(to_user=user, accepted=True).values_list('from_user', flat=True)
    all_friend_ids = list(sent) + list(received)
    return User.objects.filter(id__in=all_friend_ids)

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

        # Get friends using the helper function
        friends = get_friends(request.user)

        friend_status_list = []
        for user in all_users:
            sent = FriendRequest.objects.filter(from_user=request.user, to_user=user, accepted=False).exists()
            received = FriendRequest.objects.filter(from_user=user, to_user=request.user, accepted=False).exists()
            friends_check = FriendRequest.objects.filter(
                ((Q(from_user=request.user) & Q(to_user=user)) |
                (Q(from_user=user) & Q(to_user=request.user))) & Q(accepted=True)
            ).exists()
            friend_status_list.append({
                "id": user.id,
                "username": user.username,
                "status": (
                    "friends" if friends_check else
                    "request_sent" if sent else
                    "request_received" if received else
                    "none"
                )
            })

        context = {
            'pending_requests': requests,
            'all_users': friend_status_list,
            'unread_notifications': unread_notifications,
            'notification_count': notification_count,
            'friends': friends,
        }
    return context

def base_context(request):
    """
    Add common context variables to all templates
    """
    context = {}
    
    if request.user.is_authenticated:
        # Get unread notifications count
        unread_notifications = Notification.objects.filter(
            user=request.user, 
            is_read=False
        ).order_by('-created_at')[:5]
        
        notification_count = Notification.objects.filter(
            user=request.user, 
            is_read=False
        ).count()
        
        # Get pending friend requests
        pending_requests = FriendRequest.objects.filter(
            to_user=request.user, 
            accepted=False
        )
        
        # Get friends list
        friends = get_friends(request.user)
        
        context.update({
            'unread_notifications': unread_notifications,
            'notification_count': notification_count,
            'pending_requests': pending_requests,
            'friends': friends,
        })
    
    return context
