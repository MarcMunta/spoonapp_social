from django.http import JsonResponse
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.contrib.sessions.models import Session
from django.utils.timezone import now
from .models import Post, PostLike, PostComment, PostShare, Profile, PostCommentLike, Chat, Message, Notification, Story
from .forms import PostForm, CommentForm, ProfileForm, StoryForm
from .models import FriendRequest, StoryView
from .models import PostCategory
from django.utils import timezone
from django.db.models import Q, Prefetch, Count
from django.template.loader import render_to_string
import json

def _build_feed_context(show_posts=True):
    """Return context for feed-related views."""
    posts = (
        Post.objects.all()
        .annotate(comment_count=Count("postcomment", distinct=True))
        .order_by("-created_at")
        if show_posts
        else Post.objects.none()
    )
    if show_posts:
        posts = posts.prefetch_related(
            Prefetch(
                "postcomment_set",
                queryset=PostComment.objects.filter(parent__isnull=True)
                .annotate(num_likes=Count("postcommentlike"))
                .order_by("-num_likes", "-created_at")
                .prefetch_related(
                    Prefetch(
                        "replies",
                        queryset=PostComment.objects.annotate(num_likes=Count("postcommentlike"))
                        .order_by("-num_likes", "-created_at"),
                    )
                ),
            )
        )
    post_form = PostForm()
    comment_form = CommentForm()
    return {
        "posts": posts,
        "post_form": post_form,
        "comment_form": comment_form,
    }

def get_friends(user):
    sent = FriendRequest.objects.filter(from_user=user, accepted=True).values_list('to_user', flat=True)
    received = FriendRequest.objects.filter(to_user=user, accepted=True).values_list('from_user', flat=True)
    all_friend_ids = list(sent) + list(received)
    return User.objects.filter(id__in=all_friend_ids)

def home(request):
    context = _build_feed_context()
    context['show_form'] = False

    if request.user.is_authenticated:
        Story.objects.filter(expires_at__lte=timezone.now()).delete()
        context['friends'] = get_friends(request.user)
        active_stories = Story.objects.filter(expires_at__gt=timezone.now()).select_related('user').order_by('created_at')

        user_story_list = active_stories.filter(user=request.user)
        context['user_story_data'] = {
            'urls': [st.media_file.url for st in user_story_list],
            'expires': [st.expires_at.isoformat() for st in user_story_list],
            'ids': [st.id for st in user_story_list],
        }

        friend_story_map = {}
        for st in active_stories.filter(user__in=context['friends']).exclude(user=request.user):
            entry = friend_story_map.setdefault(st.user, {'urls': [], 'expires': [], 'ids': []})
            entry['urls'].append(st.media_file.url)
            entry['expires'].append(st.expires_at.isoformat())
            entry['ids'].append(st.id)
        context['friend_stories'] = friend_story_map
        context['story_form'] = StoryForm()

    return render(request, 'social/pages/feed.html', context)

def feed(request):
    context = _build_feed_context(show_posts=False)
    context['show_form'] = True

    if request.user.is_authenticated:
        Story.objects.filter(expires_at__lte=timezone.now()).delete()
        context['friends'] = get_friends(request.user)
        active_stories = Story.objects.filter(expires_at__gt=timezone.now()).select_related('user').order_by('created_at')

        user_story_list = active_stories.filter(user=request.user)
        context['user_story_data'] = {
            'urls': [st.media_file.url for st in user_story_list],
            'expires': [st.expires_at.isoformat() for st in user_story_list],
            'ids': [st.id for st in user_story_list],
        }

        friend_story_map = {}
        for st in active_stories.filter(user__in=context['friends']).exclude(user=request.user):
            entry = friend_story_map.setdefault(st.user, {'urls': [], 'expires': [], 'ids': []})
            entry['urls'].append(st.media_file.url)
            entry['expires'].append(st.expires_at.isoformat())
            entry['ids'].append(st.id)
        context['friend_stories'] = friend_story_map
        context['story_form'] = StoryForm()

    context['hide_profile_icon'] = False
    return render(request, 'social/pages/feed.html', context)



@login_required
def create_post(request):
    if request.method == 'POST':
        form = PostForm(request.POST, request.FILES)
        if form.is_valid():
            new_post = form.save(commit=False)
            new_post.user = request.user
            new_post.save()
            form.save_m2m()
    return redirect('home')


@login_required
def upload_story(request):
    if request.method == 'POST':
        form = StoryForm(request.POST, request.FILES)
        if form.is_valid():
            story = form.save(commit=False)
            story.user = request.user
            story.save()
    return redirect('home')


@login_required
def like_post(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    like, created = PostLike.objects.get_or_create(user=request.user, post=post)
    if not created:
        like.delete()
    if request.headers.get("x-requested-with") == "XMLHttpRequest":
        return JsonResponse({"likes": post.postlike_set.count()})
    return redirect('home')


@login_required
def share_post(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    PostShare.objects.create(user=request.user, post=post)
    return redirect('home')


@login_required
def comment_post(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    if request.method == 'POST':
        form = CommentForm(request.POST)
        if form.is_valid():
            parent_id = request.POST.get('parent')
            parent = None
            if parent_id:
                parent = PostComment.objects.filter(id=parent_id, post=post).first()
            PostComment.objects.create(
                user=request.user,
                post=post,
                parent=parent,
                content=form.cleaned_data['content']
            )
    return redirect('home')

@login_required
def friend_requests_view(request):
    requests = FriendRequest.objects.filter(to_user=request.user, accepted=False)
    return render(request, 'social/pages/friend_requests.html', {'requests': requests})

@login_required
def accept_friend_request(request, req_id):
    req = get_object_or_404(FriendRequest, id=req_id, to_user=request.user)
    req.accepted = True
    req.save()
    
    # Create notification for the friend request sender
    Notification.objects.create(
        user=req.from_user,
        notification_type='friend_accepted',
        title=f'{request.user.username} accepted your friend request',
        message=f'You are now friends with {request.user.username}',
        related_user=request.user
    )
    
    return redirect('friend_requests')

@login_required
def reject_friend_request(request, req_id):
    req = get_object_or_404(FriendRequest, id=req_id, to_user=request.user)
    req.delete()
    return redirect('friend_requests')

@login_required
def like_comment(request, comment_id):
    comment = get_object_or_404(PostComment, id=comment_id)
    like, created = PostCommentLike.objects.get_or_create(user=request.user, comment=comment)
    if not created:
        like.delete()
    if request.headers.get("x-requested-with") == "XMLHttpRequest":
        return JsonResponse({"likes": comment.postcommentlike_set.count()})
    return redirect('home')

@login_required
def follow_user(request, username):
    target_user = get_object_or_404(User, username=username)
    existing_request = FriendRequest.objects.filter(from_user=request.user, to_user=target_user)
    if not existing_request.exists() and request.user != target_user:
        FriendRequest.objects.create(from_user=request.user, to_user=target_user)
    return redirect('profile', username=username)

@login_required
def unfollow_user(request, username):
    target_user = get_object_or_404(User, username=username)
    FriendRequest.objects.filter(from_user=request.user, to_user=target_user).delete()
    # Opcionalmente, también elimina si ya son amigos (si así lo gestionas)
    request.user.profile.friends.remove(target_user)
    return redirect('profile', username=username)

def post_detail(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    return render(request, 'social/pages/post_detail.html', {'post': post})

def profile(request, username): 
    profile_user = get_object_or_404(User, username=username)
    posts = Post.objects.filter(user=profile_user).order_by('-created_at').prefetch_related('categories')
    user_profile, _ = Profile.objects.get_or_create(user=profile_user)
    categories = PostCategory.objects.exclude(slug__isnull=True)  # Excluir categorías sin slug

    posts_by_category = {'all': list(posts)}
    for category in categories:
        posts_by_category[category.slug] = list(posts.filter(categories__slug=category.slug))

    is_following = False
    if request.user.is_authenticated and request.user != profile_user:
        is_following = FriendRequest.objects.filter(
            Q(from_user=request.user, to_user=profile_user, accepted=True) |
            Q(from_user=profile_user, to_user=request.user, accepted=True)
        ).exists()

    if request.method == 'POST' and request.user == profile_user:
        form = ProfileForm(request.POST, request.FILES, instance=user_profile)
        if form.is_valid():
            form.save()
            return redirect('profile', username=username)
    else:
        form = ProfileForm(instance=user_profile)

    context = {
        'profile_user': profile_user,
        'user_profile': user_profile,
        'posts': posts,
        'form': form,
        'is_following': is_following,
        'total_matches': PostLike.objects.filter(post__user=profile_user).count(),
        'total_friends': get_friends(profile_user).count(),
        'friends': get_friends(request.user),
        'categories': categories,
        'posts_by_category': posts_by_category,
    }

    if request.user == profile_user:
        context['story_form'] = StoryForm()

    return render(request, 'social/pages/profile.html', context)


@login_required
def search_users(request):
    if request.method == "GET":
        query = request.GET.get("q", "")
        users = User.objects.filter(
            Q(username__icontains=query) | Q(email__icontains=query)
        ).exclude(id=request.user.id)[:10]

        results = []
        for user in users:
            results.append({
                "id": user.id,
                "username": user.username,
                "email": user.email,
                "avatar": user.profile.profile_picture.url if hasattr(user, "profile") and user.profile.profile_picture else "",
            })

        return JsonResponse(results, safe=False)

@login_required
def send_friend_request(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body)
            to_user_id = data.get("user_id")
            to_user = User.objects.get(id=to_user_id)
            from_user = request.user

            if not FriendRequest.objects.filter(from_user=from_user, to_user=to_user).exists():
                FriendRequest.objects.create(from_user=from_user, to_user=to_user)
                return JsonResponse({"success": True})
            else:
                return JsonResponse({"error": "Request already sent"}, status=400)

        except User.DoesNotExist:
            return JsonResponse({"error": "User not found"}, status=404)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)

    return JsonResponse({"error": "Invalid method"}, status=405)


def load_comments(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    offset = int(request.GET.get("offset", 0))
    limit = int(request.GET.get("limit", 10))
    comments_qs = (
        post.postcomment_set.filter(parent__isnull=True)
        .annotate(num_likes=Count("postcommentlike"))
        .order_by("-num_likes", "-created_at")[offset : offset + limit]
        .prefetch_related("replies")
    )
    html = render_to_string(
        "social/partials/comments_partial.html",
        {"comments": comments_qs, "user": request.user},
    )
    total = post.postcomment_set.filter(parent__isnull=True).count()
    has_more = offset + limit < total
    return JsonResponse({"html": html, "has_more": has_more})

def get_user_online_status(user):
    sessions = Session.objects.filter(expire_date__gte=now())
    for session in sessions:
        data = session.get_decoded()
        if data.get('_auth_user_id') == str(user.id):
            return True
    return False

@login_required
def friends_list_view(request):
    user = request.user
    friends = FriendRequest.objects.filter(
        (Q(from_user=user) | Q(to_user=user)) & Q(accepted=True)
    )

    all_friends = []
    for f in friends:
        friend = f.to_user if f.from_user == user else f.from_user
        online = get_user_online_status(friend)
        all_friends.append({'user': friend, 'online': online})

    return render(request, 'social/friends_panel.html', {
        'friends': all_friends
    })

@login_required
def chat_list(request):
    """Display list of all chats for the current user"""
    user_chats = Chat.objects.filter(participants=request.user).prefetch_related('participants', 'messages')
    
    chat_data = []
    for chat in user_chats:
        other_user = chat.get_other_participant(request.user)
        last_msg = chat.last_message()
        unread_count = chat.messages.filter(read=False).exclude(sender=request.user).count()
        
        chat_data.append({
            'chat': chat,
            'other_user': other_user,
            'last_message': last_msg,
            'unread_count': unread_count
        })
    
    return render(request, 'social/chat_list.html', {'chat_data': chat_data})

@login_required
def load_messages(request, chat_id):
    """Load messages for AJAX requests with pagination support"""
    chat = get_object_or_404(Chat, id=chat_id, participants=request.user)
    
    # Get pagination parameters
    before_id = request.GET.get('before')
    after_id = request.GET.get('after')
    limit = int(request.GET.get('limit', 20))
    
    # Base queryset
    messages_qs = chat.messages.all().order_by('-sent_at')
    
    # Filter messages before a specific ID (for loading older messages)
    if before_id:
        try:
            before_message = chat.messages.get(id=before_id)
            messages_qs = messages_qs.filter(sent_at__lt=before_message.sent_at)
        except Message.DoesNotExist:
            pass
    
    # Filter messages after a specific ID (for loading newer messages)
    if after_id:
        try:
            after_message = chat.messages.get(id=after_id)
            messages_qs = messages_qs.filter(sent_at__gt=after_message.sent_at).order_by('sent_at')
        except Message.DoesNotExist:
            pass
    
    # Get messages with limit + 1 to check if there are more
    messages = list(messages_qs[:limit + 1])
    
    # Check if there are more messages
    has_more = len(messages) > limit
    if has_more:
        messages = messages[:limit]  # Remove the extra message
    
    # Reverse to get chronological order for older messages
    if before_id or not after_id:
        messages.reverse()
    
    messages_data = []
    for msg in messages:
        messages_data.append({
            'id': msg.id,
            'sender': msg.sender.username,
            'content': msg.content,
            'sent_at': msg.sent_at.strftime('%H:%M'),
            'is_mine': msg.sender == request.user
        })
    
    return JsonResponse({
        'messages': messages_data,
        'has_more': has_more,
        'count': len(messages_data),
        'direction': 'before' if before_id else 'after' if after_id else 'initial'
    })

@login_required
def chat_detail(request, chat_id):
    """Display messages in a specific chat with enhanced functionality"""
    chat = get_object_or_404(Chat, id=chat_id, participants=request.user)
    other_user = chat.get_other_participant(request.user)
    
    # Mark messages as read
    chat.messages.filter(read=False).exclude(sender=request.user).update(read=True)
    
    # Get most recent messages (latest 25 for initial load to allow for smooth scrolling)
    messages = chat.messages.order_by('-sent_at')[:25]
    messages = reversed(messages)  # Show in chronological order
    
    if request.method == 'POST':
        content = request.POST.get('content', '').strip()
        if content:
            message = Message.objects.create(
                chat=chat,
                sender=request.user,
                content=content
            )
            chat.last_message_at = now()
            chat.save()
            
            # Create notification for the recipient only if they're not online in the chat
            try:
                # Only create notification if the user is not currently viewing this chat
                Notification.objects.create(
                    user=other_user,
                    notification_type='message',
                    title=f'New message from {request.user.username}',
                    message=content[:50] + '...' if len(content) > 50 else content,
                    related_user=request.user,
                    related_chat=chat
                )
            except Exception as e:
                # Silently handle notification creation errors
                pass
            
            if request.headers.get("x-requested-with") == "XMLHttpRequest":
                return JsonResponse({
                    'success': True,
                    'message_id': message.id,
                    'timestamp': message.sent_at.strftime('%H:%M')
                })
            return redirect('chat_detail', chat_id=chat.id)
    
    return render(request, 'social/chat_detail.html', {
        'chat': chat,
        'other_user': other_user,
        'messages': messages,
        'now': timezone.now(),
    })

@login_required
def start_chat(request, user_id):
    """Start or continue a chat with a friend"""
    other_user = get_object_or_404(User, id=user_id)
    
    # Check if they are friends
    are_friends = FriendRequest.objects.filter(
        ((Q(from_user=request.user) & Q(to_user=other_user)) |
         (Q(from_user=other_user) & Q(to_user=request.user))) & Q(accepted=True)
    ).exists()
    
    if not are_friends:
        return redirect('home')
    
    # Find existing chat or create new one
    existing_chat = Chat.objects.filter(
        participants=request.user
    ).filter(
        participants=other_user
    ).first()
    
    if existing_chat:
        return redirect('chat_detail', chat_id=existing_chat.id)
    else:
        new_chat = Chat.objects.create()
        new_chat.participants.add(request.user, other_user)
        return redirect('chat_detail', chat_id=new_chat.id)

@login_required
def delete_story(request, story_id):
    """Delete a story owned by the current user"""
    story = get_object_or_404(Story, id=story_id, user=request.user)
    if request.method == 'POST':
        story.delete()
        if request.headers.get("x-requested-with") == "XMLHttpRequest":
            return JsonResponse({'success': True})
    return redirect('home')


@login_required
def view_story(request, story_id):
    """Register a view and return total views"""
    story = get_object_or_404(Story, id=story_id)
    if request.user != story.user:
        StoryView.objects.get_or_create(story=story, viewer=request.user)
    views = StoryView.objects.filter(story=story).values('viewer').distinct().count()
    if request.headers.get("x-requested-with") == "XMLHttpRequest":
        return JsonResponse({'views': views})
    return JsonResponse({'views': views})


@login_required
def reply_story(request, story_id):
    """Send a chat message in reply to a story."""
    story = get_object_or_404(Story, id=story_id)
    if request.user == story.user:
        if request.headers.get("x-requested-with") == "XMLHttpRequest":
            return JsonResponse({'error': 'Cannot reply to own story.'}, status=403)
        return redirect('home')
    if request.method == 'POST':
        content = request.POST.get('content', '').strip()
        chat = Chat.objects.filter(participants=request.user).filter(participants=story.user).first()
        if not chat:
            chat = Chat.objects.create()
            chat.participants.add(request.user, story.user)
        Message.objects.create(chat=chat, sender=request.user, content=content, story=story)
        chat.last_message_at = now()
        chat.save()
        if request.headers.get("x-requested-with") == "XMLHttpRequest":
            return JsonResponse({'success': True, 'chat_id': chat.id})
        return redirect('chat_detail', chat_id=chat.id)
    return redirect('home')

@login_required
def notifications_view(request):
    """Display all notifications for the current user"""
    notifications = Notification.objects.filter(user=request.user)
    
    # Mark all as read when viewing
    Notification.objects.filter(user=request.user, is_read=False).update(is_read=True)
    
    return render(request, 'social/notifications.html', {'notifications': notifications})

@login_required
def mark_notification_read(request, notification_id):
    """Mark a specific notification as read via AJAX"""
    notification = get_object_or_404(Notification, id=notification_id, user=request.user)
    notification.is_read = True
    notification.save()
    
    if request.headers.get("x-requested-with") == "XMLHttpRequest":
        unread_count = Notification.objects.filter(user=request.user, is_read=False).count()
        return JsonResponse({'success': True, 'unread_count': unread_count})
    
    return redirect('notifications')

@login_required
def get_notifications_count(request):
    """Get unread notifications count via AJAX"""
    if request.headers.get("x-requested-with") == "XMLHttpRequest":
        count = Notification.objects.filter(user=request.user, is_read=False).count()
        return JsonResponse({'unread_count': count})
    return JsonResponse({'error': 'Invalid request'}, status=400)

