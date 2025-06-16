from django.http import JsonResponse
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.shortcuts import render
from .models import Post, PostLike, PostComment, PostShare, Profile, PostCommentLike
from .forms import PostForm, CommentForm, ProfileForm
from .models import FriendRequest
from django.db.models import Q
import json


def _build_feed_context():
    posts = Post.objects.all().order_by('-created_at')
    post_form = PostForm()
    comment_form = CommentForm()
    return {
        'posts': posts,
        'post_form': post_form,
        'comment_form': comment_form,
    }


def home(request):
    context = _build_feed_context()
    context['show_form'] = False
    return render(request, 'social/feed.html', context)


def feed(request):
    context = _build_feed_context()
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
    return render(request, 'friend_requests.html', {'requests': requests})

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