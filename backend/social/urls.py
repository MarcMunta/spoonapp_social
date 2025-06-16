from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('subir-publicacion/', views.feed, name='subir_publicacion'),
    path('post/new/', views.create_post, name='create_post'),
    path('post/<int:post_id>/like/', views.like_post, name='like_post'),
    path('post/<int:post_id>/share/', views.share_post, name='share_post'),
    path('post/<int:post_id>/comment/', views.comment_post, name='comment_post'),
    path('post/<int:post_id>/comments/', views.load_comments, name='load_comments'),
    path('comment/<int:comment_id>/like/', views.like_comment, name='like_comment'),
    path('profile/<str:username>/', views.profile, name='profile'),
    path('friend-requests/', views.friend_requests_view, name='friend_requests'),
    path('friend-requests/accept/<int:req_id>/', views.accept_friend_request, name='accept_friend_request'),
    path('friend-requests/reject/<int:req_id>/', views.reject_friend_request, name='reject_friend_request'),
    path('send-friend-request/', views.send_friend_request, name='send_friend_request'),
    path("api/search-users/", views.search_users, name="search_users"),
    path('follow/<str:username>/', views.follow_user, name='follow'),
    path('unfollow/<str:username>/', views.unfollow_user, name='unfollow'),
    path('chats/', views.chat_list, name='chat_list'),
    path('chat/<int:chat_id>/', views.chat_detail, name='chat_detail'),
    path('start-chat/<int:user_id>/', views.start_chat, name='start_chat'),
    path('chat/<int:chat_id>/messages/', views.load_messages, name='load_messages'),
    path('notifications/', views.notifications_view, name='notifications'),
    path('mark-notification-read/<int:notification_id>/', views.mark_notification_read, name='mark_notification_read'),
    path('api/notifications-count/', views.get_notifications_count, name='notifications_count'),
    path('post/<int:post_id>/', views.post_detail, name='post_detail')
]
