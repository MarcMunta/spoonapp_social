from django.contrib.auth.models import User
from .models import FriendRequest, Notification, Block
from .default_avatar import DEFAULT_AVATAR_DATA_URL
from django.db.models import Q

def get_friends(user):
    if not user.is_authenticated:
        return User.objects.none()

    sent_ids = FriendRequest.objects.filter(from_user=user, accepted=True).values_list('to_user', flat=True)
    received_ids = FriendRequest.objects.filter(to_user=user, accepted=True).values_list('from_user', flat=True)
    mutual_ids = set(sent_ids).intersection(received_ids)
    return User.objects.filter(id__in=mutual_ids)

def get_random_users(user, limit=None):
    """Return random users near the user if possible."""
    if not user.is_authenticated:
        return []

    qs = User.objects.exclude(id=user.id)
    blocked_ids = Block.objects.filter(blocker=user).values_list("blocked_id", flat=True)
    blocking_ids = Block.objects.filter(blocked=user).values_list("blocker_id", flat=True)
    qs = qs.exclude(id__in=blocked_ids).exclude(id__in=blocking_ids)

    # Try to find nearby users based on the city portion of the location
    city = ""
    if hasattr(user, "profile") and user.profile.location:
        city = user.profile.location.split(",")[0].strip()

    users = []
    if city:
        nearby_qs = qs.filter(profile__location__istartswith=city)
        if limit is not None:
            nearby = list(nearby_qs.order_by("?")[:limit])
        else:
            nearby = list(nearby_qs.order_by("?"))
        users.extend(nearby)

        if limit is not None:
            remaining = limit - len(nearby)
            if remaining > 0:
                others = qs.exclude(id__in=[u.id for u in nearby]).order_by("?")[:remaining]
                users.extend(list(others))
    else:
        if limit is not None:
            users = list(qs.order_by("?")[:limit])
        else:
            users = list(qs.order_by("?"))

    return users

def friend_requests_processor(request):
    context = {}
    if hasattr(request, 'user') and request.user.is_authenticated:
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
    context = {
        'default_avatar_data_url': DEFAULT_AVATAR_DATA_URL,
    }
    
    if hasattr(request, 'user') and request.user.is_authenticated:
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
        suggested_users = get_random_users(request.user)
        
        context.update({
            'unread_notifications': unread_notifications,
            'notification_count': notification_count,
            'pending_requests': pending_requests,
            'friends': friends,
            'suggested_users': suggested_users,
        })
    
    return context
