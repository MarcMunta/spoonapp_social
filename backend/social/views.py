from django.http import JsonResponse
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.contrib.sessions.models import Session
from django.utils.timezone import now
from .models import Post, PostLike, PostComment, PostShare, Profile, PostCommentLike
from .forms import PostForm, CommentForm, ProfileForm
from .models import FriendRequest
from django.db.models import Q, Prefetch, Count
from django.template.loader import render_to_string
import json


def _build_feed_context(show_posts=True):
    """Return context for feed-related views.

    Parameters
    ----------
    show_posts: bool, optional
        Whether to include the queryset of posts. On the page for creating a
        publication we only want to display the form, not the posts
        themselves.
    """

    posts = Post.objects.all().order_by("-created_at") if show_posts else Post.objects.none()
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
    # Display the main feed with all posts and without the form
    context = _build_feed_context()
    context['show_form'] = False
    context['friends'] = get_friends(request.user)  # ⬅️ AÑADIDO
    return render(request, 'social/feed.html', context)

def feed(request):
    # Page for creating a post; only show the form, not existing posts
    context = _build_feed_context(show_posts=False)
    context['show_form'] = True
    return render(request, 'social/feed.html', context)


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
    return render(request, 'social/friend_requests.html', {'requests': requests})

@login_required
def accept_friend_request(request, req_id):
    req = get_object_or_404(FriendRequest, id=req_id, to_user=request.user)
    req.accepted = True
    req.save()
    # Aquí podrías añadir una tabla de amistad real
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


def profile(request, username):
    profile_user = get_object_or_404(User, username=username)
    posts = Post.objects.filter(user=profile_user).order_by('-created_at')
    user_profile, _ = Profile.objects.get_or_create(user=profile_user)
    if request.method == 'POST' and request.user == profile_user:
        form = ProfileForm(request.POST, request.FILES, instance=user_profile)
        if form.is_valid():
            form.save()
            return redirect('profile', username=username)
    else:
        form = ProfileForm(instance=user_profile)
    return render(
        request,
        'social/profile.html',
        {
            'profile_user': profile_user,
            'posts': posts,
            'user_profile': user_profile,
            'form': form,
        },
    )

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
        "social/comments_partial.html",
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

