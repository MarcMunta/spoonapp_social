from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.shortcuts import render
from .models import Post, PostLike, PostComment, PostShare, Profile, PostCommentLike
from .forms import PostForm, CommentForm, ProfileForm
from .models import FriendRequest


def _build_feed_context(show_posts=True):
    """Return context for feed-related views.

    Parameters
    ----------
    show_posts: bool, optional
        Whether to include the queryset of posts. On the page for creating a
        publication we only want to display the form, not the posts
        themselves.
    """

    posts = (
        Post.objects.all().order_by("-created_at") if show_posts else Post.objects.none()
    )
    post_form = PostForm()
    comment_form = CommentForm()
    return {
        "posts": posts,
        "post_form": post_form,
        "comment_form": comment_form,
    }


def home(request):
    # Display the main feed with all posts and without the form
    context = _build_feed_context()
    context['show_form'] = False
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
