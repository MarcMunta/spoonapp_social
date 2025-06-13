from django.contrib import admin
from django.urls import path, include
from social import urls as social_urls

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include(social_urls)),
]
