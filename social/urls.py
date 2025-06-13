from django.urls import path
from . import views

urlpatterns = [
    path('', views.feed, name='feed'),
    path('post/new/', views.create_post, name='create_post'),
    path('post/<int:post_id>/like/', views.like_post, name='like_post'),
    path('post/<int:post_id>/share/', views.share_post, name='share_post'),
    path('post/<int:post_id>/comment/', views.comment_post, name='comment_post'),
    path('profile/<str:username>/', views.profile, name='profile'),
]
