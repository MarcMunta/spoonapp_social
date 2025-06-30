from django.http import JsonResponse
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import PasswordChangeForm
from django.contrib import messages
from django.contrib.auth import update_session_auth_hash   # ⬅ lo usaremos
from django.contrib.auth.models import User
from django.contrib.sessions.models import Session
from django.utils.timezone import now
from django.urls import reverse
from .forms import UserForm, ProfileForm, PrivacySettingsForm, SignupForm
from .models import (
    Post,
    PostLike,
    PostComment,
    PostShare,
    Profile,
    PostCommentLike,
    Chat,
    Message,
    Notification,
    Story,
    FriendRequest,
    CommunityFollow,
    StoryView,
    PostCategory,
    Block,
    StoryVisibilityBlock,
)
from .forms import PostForm, CommentForm, ProfileForm, StoryForm, UserForm
from django.utils import timezone
from django.http import HttpResponseForbidden
from django.db.models import Q, Prefetch, Count, F
import random
from django.template.loader import render_to_string
from django.views.i18n import set_language as django_set_language
from django.core.management import call_command
from django.utils.translation import gettext as _
from .default_avatar import DEFAULT_AVATAR_DATA_URL
from .context_processors import get_random_users
import requests
import sys
import json

def test_404_view(request):
    return render(request, 'errors/404.html', status=404)

def test_403_view(request):
    return render(request, 'errors/403.html', status=403)

def test_500_view(request):
    return render(request, 'errors/500.html', status=500)

# Handlers reales para producción
def custom_404(request, exception):
    return render(request, 'errors/404.html', status=404)

def custom_403(request, exception):
    return render(request, 'errors/403.html', status=403)

def custom_500(request):
    return render(request, 'errors/500.html', status=500)

def set_language(request):
    """Run Django's set_language view and compile translations."""
    response = django_set_language(request)
    try:
        call_command('compilemessages', verbosity=0)
    except Exception as exc:
        print(f'Error compiling messages: {exc}', file=sys.stderr)
    return response


def signup(request):
    if request.method == "POST":
        form = SignupForm(request.POST)
        if form.is_valid():
            user = form.save()
            user.profile.account_type = form.cleaned_data["account_type"]
            user.profile.save(update_fields=["account_type"])
            return redirect("custom_login")
    else:
        form = SignupForm()
    return render(request, "pages/signup.html", {"form": form})

def _build_feed_context(request, show_posts=True):
    """Return context for feed-related views."""
    posts_qs = Post.objects.all()
    if request.user.is_authenticated:
        blocked_ids = Block.objects.filter(blocker=request.user).values_list(
            "blocked_id", flat=True
        )
        blocking_ids = Block.objects.filter(blocked=request.user).values_list(
            "blocker_id", flat=True
        )
        posts_qs = posts_qs.exclude(user__id__in=blocked_ids).exclude(
            user__id__in=blocking_ids
        )
    posts = (
        posts_qs.annotate(
            # Count all comments including replies
            comment_count=Count("postcomment", distinct=True)
        ).order_by("-created_at")
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
    if not user.is_authenticated:
        return User.objects.none()

    sent_ids = FriendRequest.objects.filter(from_user=user, accepted=True).values_list('to_user', flat=True)
    received_ids = FriendRequest.objects.filter(to_user=user, accepted=True).values_list('from_user', flat=True)
    mutual_ids = set(sent_ids).intersection(received_ids)
    qs = User.objects.filter(id__in=mutual_ids)
    blocked_ids = Block.objects.filter(blocker=user).values_list('blocked_id', flat=True)
    blocking_ids = Block.objects.filter(blocked=user).values_list('blocker_id', flat=True)
    return qs.exclude(id__in=blocked_ids).exclude(id__in=blocking_ids)

def home(request):
    context = _build_feed_context(request)
    context['show_form'] = False

    if request.user.is_authenticated:
        Story.objects.filter(expires_at__lte=timezone.now()).delete()
        context['friends'] = get_friends(request.user)
        hidden_owners = StoryVisibilityBlock.objects.filter(
            hidden_user=request.user
        ).values_list('story_owner', flat=True)
        blocked_ids = Block.objects.filter(blocker=request.user).values_list('blocked_id', flat=True)
        blocking_ids = Block.objects.filter(blocked=request.user).values_list('blocker_id', flat=True)
        active_stories = (
            Story.objects.filter(expires_at__gt=timezone.now(), media_data__isnull=False)
            .exclude(user__in=hidden_owners)
            .exclude(user__id__in=blocked_ids)
            .exclude(user__id__in=blocking_ids)
            .select_related('user')
            .order_by('created_at')
        )

        user_story_list = active_stories.filter(user=request.user)
        context['user_story_data'] = {
            'urls': [st.media_data_url for st in user_story_list],
            'types': [st.media_mime or '' for st in user_story_list],
            'expires': [st.expires_at.isoformat() for st in user_story_list],
            'created': [st.created_at.isoformat() for st in user_story_list],
            'ids': [st.id for st in user_story_list],
            'thumb': user_story_list[0].media_data_url if user_story_list else None,
        }

        friend_story_map = {}
        for st in active_stories.filter(user__in=context['friends']).exclude(user=request.user):
            entry = friend_story_map.setdefault(
                st.user,
                {'urls': [], 'types': [], 'expires': [], 'created': [], 'ids': [], 'thumb': None},
            )
            entry['urls'].append(st.media_data_url)
            entry['types'].append(st.media_mime or '')
            entry['expires'].append(st.expires_at.isoformat())
            entry['created'].append(st.created_at.isoformat())
            entry['ids'].append(st.id)
            if entry['thumb'] is None:
                entry['thumb'] = st.media_data_url
        context['friend_stories'] = friend_story_map
        context['story_form'] = StoryForm()

    return render(request, 'pages/feed.html', context)

def feed(request):
    context = _build_feed_context(request, show_posts=False)
    context['show_form'] = True

    if request.user.is_authenticated:
        Story.objects.filter(expires_at__lte=timezone.now()).delete()
        context['friends'] = get_friends(request.user)
        hidden_owners = StoryVisibilityBlock.objects.filter(
            hidden_user=request.user
        ).values_list('story_owner', flat=True)
        blocked_ids = Block.objects.filter(blocker=request.user).values_list('blocked_id', flat=True)
        blocking_ids = Block.objects.filter(blocked=request.user).values_list('blocker_id', flat=True)
        active_stories = (
            Story.objects.filter(expires_at__gt=timezone.now(), media_data__isnull=False)
            .exclude(user__in=hidden_owners)
            .exclude(user__id__in=blocked_ids)
            .exclude(user__id__in=blocking_ids)
            .select_related('user')
            .order_by('created_at')
        )

        user_story_list = active_stories.filter(user=request.user)
        context['user_story_data'] = {
            'urls': [st.media_data_url for st in user_story_list],
            'types': [st.media_mime or '' for st in user_story_list],
            'expires': [st.expires_at.isoformat() for st in user_story_list],
            'created': [st.created_at.isoformat() for st in user_story_list],
            'ids': [st.id for st in user_story_list],
            'thumb': user_story_list[0].media_data_url if user_story_list else None,
        }

        friend_story_map = {}
        for st in active_stories.filter(user__in=context['friends']).exclude(user=request.user):
            entry = friend_story_map.setdefault(
                st.user,
                {'urls': [], 'types': [], 'expires': [], 'created': [], 'ids': [], 'thumb': None},
            )
            entry['urls'].append(st.media_data_url)
            entry['types'].append(st.media_mime or '')
            entry['expires'].append(st.expires_at.isoformat())
            entry['created'].append(st.created_at.isoformat())
            entry['ids'].append(st.id)
            if entry['thumb'] is None:
                entry['thumb'] = st.media_data_url
        context['friend_stories'] = friend_story_map
        context['story_form'] = StoryForm()

    context['hide_profile_icon'] = False

    category_slug = request.GET.get("category")
    if category_slug and category_slug != "all":
        context["posts"] = context["posts"].filter(categories__slug=category_slug)

    if request.headers.get("x-requested-with") == "XMLHttpRequest":
        return render(request, "partials/posts_list.html", {"posts": context["posts"]})

    return render(request, 'pages/feed.html', context)


@login_required(login_url='/custom-login/')
def create_post(request):
    if request.method == 'POST':
        form = PostForm(request.POST, request.FILES)
        if form.is_valid():
            new_post = form.save(commit=False)
            new_post.user = request.user
            new_post.save()
            form.save_m2m()
            if request.user.profile.account_type == 'community':
                followers = CommunityFollow.objects.filter(community=request.user).select_related('user')
                url = request.build_absolute_uri(reverse('post_detail', args=[new_post.id]))
                snippet = new_post.caption[:50] + ('...' if len(new_post.caption) > 50 else '') if new_post.caption else _('Ha subido una nueva publicación.')
                for f in followers:
                    Notification.objects.create(
                        user=f.user,
                        notification_type='community_post',
                        title=_('Nueva publicación en %(name)s') % {'name': request.user.username},
                        message=snippet,
                        related_user=request.user,
                        target_url=url,
                    )
    return redirect('home')

@login_required(login_url='/custom-login/')
def delete_post(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    if request.user != post.user:
        return HttpResponseForbidden("No tienes permiso para eliminar esta publicación.")
    if request.method == 'POST':
        post.delete()
        if request.headers.get("x-requested-with") == "XMLHttpRequest":
            return JsonResponse({'success': True})
        return redirect('home')

@login_required(login_url='/custom-login/')
def upload_story(request):
    if request.method == 'POST':
        form = StoryForm(request.POST, request.FILES)
        if form.is_valid():
            story = form.save(commit=False)
            story.user = request.user
            story.save()
            if request.user.profile.account_type == 'community':
                followers = CommunityFollow.objects.filter(community=request.user).select_related('user')
                url = request.build_absolute_uri(reverse('profile', args=[request.user.username]))
                for f in followers:
                    Notification.objects.create(
                        user=f.user,
                        notification_type='community_post',
                        title=_('Nueva publicación en %(name)s') % {'name': request.user.username},
                        message=_('Ha subido una nueva historia.'),
                        related_user=request.user,
                        target_url=url,
                    )
    return redirect('home')

@login_required(login_url='/custom-login/')
def like_post(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    like, created = PostLike.objects.get_or_create(user=request.user, post=post)
    if not created:
        like.delete()
    if request.headers.get("x-requested-with") == "XMLHttpRequest":
        return JsonResponse({"likes": post.postlike_set.count()})
    return redirect(request.META.get("HTTP_REFERER", "home"))

@login_required(login_url='/custom-login/')
def share_post(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    PostShare.objects.create(user=request.user, post=post)
    return redirect('home')


@login_required(login_url='/custom-login/')
def comment_post(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    if request.method == 'POST':
        form = CommentForm(request.POST)
        if form.is_valid():
            parent_id = request.POST.get('parent')
            parent = None
            if parent_id:
                parent = PostComment.objects.filter(id=parent_id, post=post).first()
            content = form.cleaned_data['content']
            if parent:
                mention = f"@{parent.user.username} "
                if not content.startswith(mention):
                    content = mention + content
            comment = PostComment.objects.create(
                user=request.user,
                post=post,
                parent=parent,
                content=content
            )
            if request.headers.get("x-requested-with") == "XMLHttpRequest":
                html = render_to_string(
                    "partials/comments/comments_partial.html",
                    {
                        "comments": [comment],
                        "user": request.user,
                        "comment_form": CommentForm(),
                    },
                    request=request,
                )
                return JsonResponse(
                    {
                        "success": True,
                        "html": html,
                        "post_id": post.id,
                        "parent_id": parent.id if parent else None,
                    }
                )
    return redirect(request.META.get("HTTP_REFERER", "home"))

@login_required(login_url='/custom-login/')
def friend_requests_view(request):
    requests = FriendRequest.objects.filter(to_user=request.user, accepted=False)
    return render(request, 'pages/friend_requests.html', {'requests': requests})

@login_required(login_url='/custom-login/')
def accept_friend_request(request, req_id):
    friend_request = get_object_or_404(FriendRequest, id=req_id, to_user=request.user)
    friend_request.accepted = True
    friend_request.save()
    
    # Create notification for the friend request sender
    Notification.objects.create(
        user=friend_request.from_user,
        notification_type='friend_accepted',
        title=f'{request.user.username} accepted your friend request',
        message=f'You are now friends with {request.user.username}',
        related_user=request.user
    )
    
    return redirect('friend_requests')

@login_required(login_url='/custom-login/')
def reject_friend_request(request, req_id):
    req = get_object_or_404(FriendRequest, id=req_id, to_user=request.user)
    req.delete()
    return redirect('friend_requests')


@login_required(login_url='/custom-login/')
def follow_community(request, username):
    community = get_object_or_404(User, username=username, profile__account_type='community')
    if request.user == community:
        return redirect('profile', username=username)
    follow, created = CommunityFollow.objects.get_or_create(user=request.user, community=community)
    if created:
        Profile.objects.filter(user=community).update(followers=F('followers') + 1)
    return redirect('profile', username=username)


@login_required(login_url='/custom-login/')
def unfollow_community(request, username):
    community = get_object_or_404(User, username=username, profile__account_type='community')
    if request.user == community:
        return redirect('profile', username=username)
    deleted, _ = CommunityFollow.objects.filter(user=request.user, community=community).delete()
    if deleted:
        Profile.objects.filter(user=community, followers__gt=0).update(followers=F('followers') - 1)
    return redirect('profile', username=username)

@login_required(login_url='/custom-login/')
def like_comment(request, comment_id):
    comment = get_object_or_404(PostComment, id=comment_id)
    like, created = PostCommentLike.objects.get_or_create(user=request.user, comment=comment)
    if not created:
        like.delete()
    if request.headers.get("x-requested-with") == "XMLHttpRequest":
        return JsonResponse({"likes": comment.postcommentlike_set.count()})
    return redirect('home')


@login_required(login_url='/custom-login/')
def delete_comment(request, comment_id):
    comment = get_object_or_404(PostComment, id=comment_id)
    if request.user != comment.user and request.user != comment.post.user:
        return HttpResponseForbidden("No tienes permiso para eliminar este comentario.")
    if request.method == 'POST':
        post = comment.post
        comment.delete()
        remaining_top = post.postcomment_set.filter(parent__isnull=True).count()
        if request.headers.get("x-requested-with") == "XMLHttpRequest":
            return JsonResponse({'success': True, 'comment_id': comment_id, 'remaining_top': remaining_top})
        return redirect('home')
    return JsonResponse({'error': 'Invalid method'}, status=405)



@login_required(login_url='/custom-login/')
def block_user(request, username):
    user_to_block = get_object_or_404(User, username=username)
    if user_to_block != request.user:
        Block.objects.get_or_create(blocker=request.user, blocked=user_to_block)
    return redirect('profile', user_to_block.username)


@login_required(login_url='/custom-login/')
def hide_stories(request, username):
    target_user = get_object_or_404(User, username=username)
    if target_user != request.user:
        StoryVisibilityBlock.objects.get_or_create(story_owner=request.user, hidden_user=target_user)
    return redirect('profile', request.user.username)


@login_required(login_url='/custom-login/')
def hidden_stories_list(request):
    blocks = StoryVisibilityBlock.objects.filter(story_owner=request.user).select_related('hidden_user__profile')
    return render(request, 'pages/hidden_stories.html', {'blocks': blocks})


@login_required(login_url='/custom-login/')
def unhide_stories(request, username):
    target_user = get_object_or_404(User, username=username)
    StoryVisibilityBlock.objects.filter(story_owner=request.user, hidden_user=target_user).delete()
    if request.headers.get('x-requested-with') == 'XMLHttpRequest':
        return JsonResponse({'success': True})
    return redirect('hidden_stories_list')


@login_required(login_url='/custom-login/')
def blocked_users_list(request):
    blocks = Block.objects.filter(blocker=request.user).select_related('blocked__profile')
    return render(request, 'pages/blocked_users.html', {'blocks': blocks})


@login_required(login_url='/custom-login/')
def unblock_user(request, username):
    target_user = get_object_or_404(User, username=username)
    Block.objects.filter(blocker=request.user, blocked=target_user).delete()
    if request.headers.get('x-requested-with') == 'XMLHttpRequest':
        return JsonResponse({'success': True})
    return redirect('blocked_users_list')

def post_detail(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    
    comment_form = CommentForm()
    comments = post.postcomment_set.filter(parent__isnull=True).select_related('user__profile').prefetch_related('replies', 'postcommentlike_set')

    return render(request, 'pages/post_detail.html', {
        'post': post,
        'comment_form': comment_form,
        'comments': comments,
    })

def profile(request, username):
    profile_user = get_object_or_404(User, username=username)
    if request.user.is_authenticated:
        if Block.objects.filter(blocker=request.user, blocked=profile_user).exists() or Block.objects.filter(blocker=profile_user, blocked=request.user).exists():
            return HttpResponseForbidden("No tienes permiso para ver este perfil.")
    posts_all = Post.objects.filter(user=profile_user).order_by('-created_at').prefetch_related('categories')
    selected_slug = request.GET.get('category')
    if selected_slug:
        posts = posts_all.filter(categories__slug=selected_slug)
    else:
        posts = posts_all
    user_profile, _ = Profile.objects.get_or_create(user=profile_user)
    categories = PostCategory.objects.exclude(slug__isnull=True)

    posts_by_category = {'all': list(posts_all)}
    for category in categories:
        posts_by_category[category.slug] = list(
            posts_all.filter(categories__slug=category.slug)
        )

    story_qs = Story.objects.filter(
        user=profile_user,
        expires_at__gt=timezone.now(),
        media_data__isnull=False,
    ).order_by('created_at')
    if request.user.is_authenticated:
        hidden_owners = StoryVisibilityBlock.objects.filter(
            hidden_user=request.user
        ).values_list('story_owner', flat=True)
        blocked_ids = Block.objects.filter(blocker=request.user).values_list('blocked_id', flat=True)
        blocking_ids = Block.objects.filter(blocked=request.user).values_list('blocker_id', flat=True)
        story_qs = story_qs.exclude(user__in=hidden_owners).exclude(user__id__in=blocked_ids).exclude(user__id__in=blocking_ids)

    profile_story_data = {
        'urls': [st.media_data_url for st in story_qs],
        'types': [st.media_mime or '' for st in story_qs],
        'expires': [st.expires_at.isoformat() for st in story_qs],
        'created': [st.created_at.isoformat() for st in story_qs],
        'ids': [st.id for st in story_qs],
        'thumb': story_qs[0].media_data_url if story_qs else None,
    }

    is_friend = False
    is_following = False

    if request.user.is_authenticated and request.user != profile_user:
        req_sent = FriendRequest.objects.filter(from_user=request.user, to_user=profile_user).first()
        req_received = FriendRequest.objects.filter(from_user=profile_user, to_user=request.user).first()

        is_friend = (
            req_sent is not None and req_received is not None and
            req_sent.accepted and req_received.accepted
        )

        is_following = False
        if profile_user.profile.account_type == 'community':
            is_following = CommunityFollow.objects.filter(user=request.user, community=profile_user).exists()
    

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
        'is_friend': is_friend,
        'is_following': is_following,
        'total_matches': PostLike.objects.filter(post__user=profile_user).count(),
        'total_friends': get_friends(profile_user).count(),
        'friends': get_friends(request.user) if request.user.is_authenticated else [],
        'categories': categories,
        'posts_by_category': posts_by_category,
        'selected_category': selected_slug or 'all',
        'profile_story_data': profile_story_data,
        # Always display the friends sidebar on the profile page so that the
        # friend search input is available.
        'hide_friends_section': False,
    }

    if request.user == profile_user:
        context['story_form'] = StoryForm()

    return render(request, 'pages/profile.html', context)

@login_required(login_url='/custom-login/')
def search_users(request):
    if request.method == "GET":
        query = request.GET.get("q", "").strip()

        # Base queryset of individual users excluding the requester
        qs = User.objects.filter(profile__account_type="individual").exclude(
            id=request.user.id
        )

        blocked_ids = Block.objects.filter(blocker=request.user).values_list(
            "blocked_id", flat=True
        )
        blocking_ids = Block.objects.filter(blocked=request.user).values_list(
            "blocker_id", flat=True
        )
        qs = qs.exclude(id__in=blocked_ids).exclude(id__in=blocking_ids)

        users = []
        if query:
            # Apply filtering when a query is provided
            qs = qs.filter(
                Q(username__icontains=query)
                | Q(email__icontains=query)
                | Q(first_name__icontains=query)
                | Q(last_name__icontains=query)
            )

            friends_ids = list(
                get_friends(request.user).values_list("id", flat=True)
            )

            # Rank by mutual friends
            candidates = list(qs)
            ranked = []
            for u in candidates:
                mutual_count = get_friends(u).filter(id__in=friends_ids).count()
                ranked.append((mutual_count, u))

            ranked.sort(key=lambda x: (-x[0], x[1].username))
            users = [u for _, u in ranked]
        else:
            # Suggest users based on interactions when no query provided
            candidates = list(qs)
            scored = []
            for u in candidates:
                likes = PostLike.objects.filter(user=request.user, post__user=u).count()
                comments = PostComment.objects.filter(user=request.user, post__user=u).count()
                scored.append((likes + comments, u))

            if scored:
                scored.sort(key=lambda x: x[0], reverse=True)
                top_user = scored.pop(0)[1]
                remaining = [u for _, u in scored]
                random.shuffle(remaining)
                users = [top_user] + remaining
            else:
                users = []

        results = []
        for user in users[:5]:
            avatar = ""
            if hasattr(user, "profile") and user.profile.profile_picture:
                avatar = user.profile.profile_picture_data_url
            results.append(
                {
                    "id": user.id,
                    "username": user.username,
                    "email": user.email,
                    "avatar": avatar,
                }
            )

        return JsonResponse(results, safe=False)


@login_required(login_url='/custom-login/')
def search_locations(request):
    """Return cities, towns or countries matching a query using Nominatim."""
    if request.method == "GET":
        query = request.GET.get("q", "").strip()
        if not query:
            return JsonResponse([], safe=False)

        url = "https://nominatim.openstreetmap.org/search"
        params = {
            "q": query,
            "format": "json",
            "addressdetails": 1,
            "limit": 5,
            "accept-language": request.LANGUAGE_CODE,
        }
        headers = {"User-Agent": "SpoonApp Social"}
        results = []
        try:
            resp = requests.get(url, params=params, headers=headers, timeout=5)
            for item in resp.json():
                if item.get("type") in {"city", "town", "village", "hamlet", "administrative", "country"}:
                    addr = item.get("address", {})
                    name = (
                        addr.get("city")
                        or addr.get("town")
                        or addr.get("village")
                        or addr.get("hamlet")
                        or addr.get("country")
                        or item.get("display_name")
                    )
                    results.append({"name": name, "display_name": item.get("display_name")})
                if len(results) >= 5:
                    break
        except Exception:
            results = []

        return JsonResponse(results, safe=False)

@login_required(login_url='/custom-login/')
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


@login_required(login_url='/custom-login/')
def update_bubble_color(request):
    if request.method == "POST":
        color = request.POST.get("color")
        valid_colors = {c for c, _ in ProfileForm.COLOR_CHOICES}
        if color in valid_colors:
            profile = request.user.profile
            profile.bubble_color = color
            profile.save(update_fields=["bubble_color"])
            return JsonResponse({"success": True, "color": color})
        return JsonResponse({"error": "Invalid color"}, status=400)
    return JsonResponse({"error": "Invalid method"}, status=405)


def load_comments(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    offset = int(request.GET.get("offset", 0))
    limit = int(request.GET.get("limit", 5))
    comments_qs = (
        post.postcomment_set.filter(parent__isnull=True)
        .annotate(num_likes=Count("postcommentlike"))
        .order_by("-num_likes", "-created_at")[offset : offset + limit]
        .prefetch_related("replies")
    )
    html = render_to_string(
        "partials/comments/comments_partial.html",
        {
            "comments": comments_qs,
            "user": request.user,
            "comment_form": CommentForm(),
        },
        request=request,
    )
    total = post.postcomment_set.filter(parent__isnull=True).count()
    has_more = offset + limit < total
    return JsonResponse({"html": html, "has_more": has_more})


def load_replies(request, comment_id):
    comment = get_object_or_404(PostComment, id=comment_id)
    offset = int(request.GET.get("offset", 0))
    limit = int(request.GET.get("limit", 3))
    replies_qs = (
        comment.replies.annotate(num_likes=Count("postcommentlike"))
        .order_by("-num_likes", "-created_at")[offset : offset + limit]
    )
    html = render_to_string(
        "partials/comments/comments_partial.html",
        {"comments": replies_qs, "user": request.user, "comment_form": CommentForm()},
        request=request,
    )
    total = comment.replies.count()
    has_more = offset + limit < total
    return JsonResponse({"html": html, "has_more": has_more})

def get_user_online_status(user):
    sessions = Session.objects.filter(expire_date__gte=now())
    for session in sessions:
        data = session.get_decoded()
        if data.get('_auth_user_id') == str(user.id):
            return True
    return False

@login_required(login_url='/custom-login/')
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

    # Template moved during project restructuring
    return render(request, 'pages/friend_requests.html', {
        'friends': all_friends
    })

@login_required(login_url='/custom-login/')
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
    
    return render(request, 'pages/chat_list.html', {'chat_data': chat_data})

@login_required(login_url='/custom-login/')
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
            'is_mine': msg.sender == request.user,
            'bubble_color': msg.sender.profile.bubble_color,
        })
    
    return JsonResponse({
        'messages': messages_data,
        'has_more': has_more,
        'count': len(messages_data),
        'direction': 'before' if before_id else 'after' if after_id else 'initial'
    })

@login_required(login_url='/custom-login/')
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
            are_friends = FriendRequest.objects.filter(
                ((Q(from_user=request.user) & Q(to_user=other_user)) |
                 (Q(from_user=other_user) & Q(to_user=request.user))) & Q(accepted=True)
            ).exists()

            # Limit non-friends to a single message
            if not are_friends and Message.objects.filter(chat=chat, sender=request.user).exists():
                if request.headers.get("x-requested-with") == "XMLHttpRequest":
                    return JsonResponse({'error': _('You can only send one message to non-friends.')}, status=403)
                return redirect('chat_detail', chat_id=chat.id)

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
            except Exception:
                # Silently handle notification creation errors
                pass
            
            if request.headers.get("x-requested-with") == "XMLHttpRequest":
                return JsonResponse({
                    'success': True,
                    'message_id': message.id,
                    'timestamp': message.sent_at.strftime('%H:%M')
                })
            return redirect('chat_detail', chat_id=chat.id)
    
    return render(request, 'pages/chat_detail.html', {
        'chat': chat,
        'other_user': other_user,
        'messages': messages,
        'now': timezone.now(),
    })

@login_required(login_url='/custom-login/')
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

@login_required(login_url='/custom-login/')
def delete_story(request, story_id):
    """Delete a story owned by the current user"""
    story = get_object_or_404(Story, id=story_id, user=request.user)
    if request.method == 'POST':
        story.delete()
        if request.headers.get("x-requested-with") == "XMLHttpRequest":
            return JsonResponse({'success': True})
    return redirect('home')


@login_required(login_url='/custom-login/')
def view_story(request, story_id):
    """Register a view and return total views"""
    story = get_object_or_404(Story, id=story_id)
    if StoryVisibilityBlock.objects.filter(story_owner=story.user, hidden_user=request.user).exists():
        return HttpResponseForbidden("No tienes permiso para ver esta historia.")
    if request.user != story.user:
        StoryView.objects.get_or_create(story=story, viewer=request.user)
    views = StoryView.objects.filter(story=story).values('viewer').distinct().count()
    if request.headers.get("x-requested-with") == "XMLHttpRequest":
        return JsonResponse({'views': views})
    return JsonResponse({'views': views})


@login_required(login_url='/custom-login/')
def story_viewers(request, story_id):
    """Return HTML list of users who viewed a story."""
    story = get_object_or_404(Story, id=story_id)
    if story.user != request.user:
        return HttpResponseForbidden("No tienes permiso para ver las vistas.")
    viewer_ids = (
        StoryView.objects.filter(story=story)
        .values_list("viewer", flat=True)
        .distinct()
    )
    viewers = Profile.objects.select_related("user").filter(user__id__in=viewer_ids)
    html = render_to_string(
        "partials/stories/story_viewers_list.html",
        {"viewers": viewers},
        request=request,
    )
    return JsonResponse({"html": html})


@login_required(login_url='/custom-login/')
def reply_story(request, story_id):
    """Send a chat message in reply to a story."""
    story = get_object_or_404(Story, id=story_id)
    if StoryVisibilityBlock.objects.filter(story_owner=story.user, hidden_user=request.user).exists():
        if request.headers.get("x-requested-with") == "XMLHttpRequest":
            return JsonResponse({'error': 'No puedes responder a esta historia.'}, status=403)
        return redirect('home')
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

        are_friends = FriendRequest.objects.filter(
            ((Q(from_user=request.user) & Q(to_user=story.user)) |
             (Q(from_user=story.user) & Q(to_user=request.user))) & Q(accepted=True)
        ).exists()

        if not are_friends and Message.objects.filter(chat=chat, sender=request.user).exists():
            if request.headers.get("x-requested-with") == "XMLHttpRequest":
                return JsonResponse({'error': _('You can only send one message to non-friends.')}, status=403)
            return redirect('chat_detail', chat_id=chat.id)

        Message.objects.create(chat=chat, sender=request.user, content=content, story=story)
        chat.last_message_at = now()
        chat.save()
        if request.headers.get("x-requested-with") == "XMLHttpRequest":
            return JsonResponse({'success': True, 'chat_id': chat.id})
        return redirect('chat_detail', chat_id=chat.id)
    return redirect('home')

@login_required(login_url='/custom-login/')
def notifications_view(request):
    """Display all notifications for the current user"""
    notifications = Notification.objects.filter(user=request.user)
    
    # Mark all as read when viewing
    Notification.objects.filter(user=request.user, is_read=False).update(is_read=True)
    
    return render(request, 'pages/notifications.html', {'notifications': notifications})

@login_required(login_url='/custom-login/')
def mark_notification_read(request, notification_id):
    """Mark a specific notification as read via AJAX"""
    notification = get_object_or_404(Notification, id=notification_id, user=request.user)
    notification.is_read = True
    notification.save()
    
    if request.headers.get("x-requested-with") == "XMLHttpRequest":
        unread_count = Notification.objects.filter(user=request.user, is_read=False).count()
        return JsonResponse({'success': True, 'unread_count': unread_count})
    
    return redirect('notifications')

@login_required(login_url='/custom-login/')
def get_notifications_count(request):
    """Get unread notifications count via AJAX"""
    if request.headers.get("x-requested-with") == "XMLHttpRequest":
        count = Notification.objects.filter(user=request.user, is_read=False).count()
        return JsonResponse({'unread_count': count})
    return JsonResponse({'error': 'Invalid request'}, status=400)


@login_required(login_url='/custom-login/')
def friends_list_partial(request):
    """Return random users for AJAX updates"""
    friends = get_random_users(request.user)
    html = render_to_string(
        "partials/friends/list.html",
        {
            "users": friends,
            "default_avatar_data_url": DEFAULT_AVATAR_DATA_URL,
        },
        request=request,
    )
    return JsonResponse({"html": html})

@login_required(login_url='/custom-login/')
def edit_profile(request, section="general"):
    """
    section puede ser: general | password | privacy
    """
    user     = request.user
    profile  = user.profile

    # =====  Formularios siempre inicializados  =====
    user_form      = UserForm(instance=user)
    profile_form   = ProfileForm(instance=profile)
    password_form  = PasswordChangeForm(user=user)
    privacy_form   = PrivacySettingsForm(instance=profile)

    # =====  Procesar POST  =====
    if request.method == "POST":
        if section == "password":
            password_form = PasswordChangeForm(user=user, data=request.POST)
            if password_form.is_valid():
                password_form.save()
                update_session_auth_hash(request, password_form.user)  # no cerrar sesión
                messages.success(request, _("Contraseña actualizada"))
                return redirect("edit_profile_section", section="password")

        elif section == "privacy":
            privacy_form = PrivacySettingsForm(request.POST, instance=profile)
            if privacy_form.is_valid():
                privacy_form.save()
                messages.success(request, _("Opciones de privacidad guardadas"))
                return redirect("edit_profile_section", section="privacy")

        else:  # general
            user_form    = UserForm(request.POST, instance=user)
            profile_form = ProfileForm(request.POST, request.FILES, instance=profile)
            if user_form.is_valid() and profile_form.is_valid():
                user_form.save()
                profile_form.save()
                messages.success(request, _("Perfil actualizado"))
                return redirect("edit_profile")      # vuelve a pestaña general

    # =====  Render  =====
    context = {
        "section": section,           # para mostrar pestaña activa
        "user_form": user_form,
        "profile_form": profile_form,
        "password_form": password_form,
        "privacy_form": privacy_form,
        "profile": profile,
    }
    return render(request, "pages/edit_profile.html", context)

@login_required(login_url='/custom-login/')
def delete_account(request):
    if request.method == "POST":
        user = request.user
        user.delete()
        return redirect("home")
    return render(request, "pages/confirm_delete.html")

