from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('feed/', views.feed, name='feed'),
    path('post/new/', views.create_post, name='create_post'),
    path('post/<int:post_id>/like/', views.like_post, name='like_post'),
    path('post/<int:post_id>/share/', views.share_post, name='share_post'),
    path('post/<int:post_id>/comment/', views.comment_post, name='comment_post'),
    path('comment/<int:comment_id>/like/', views.like_comment, name='like_comment'),
    path('profile/<str:username>/', views.profile, name='profile'),
    path('friend-requests/', views.friend_requests_view, name='friend_requests'),
    path('friend-requests/accept/<int:req_id>/', views.accept_friend_request, name='accept_friend_request'),
    path('friend-requests/reject/<int:req_id>/', views.reject_friend_request, name='reject_friend_request'),
]
