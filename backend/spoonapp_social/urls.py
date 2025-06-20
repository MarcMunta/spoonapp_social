from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from core import urls as social_urls
from django.conf.urls import handler404, handler403, handler500

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include(social_urls)),
]

# Serve uploaded media files during development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

handler404 = 'core.views.custom_404'
handler403 = 'core.views.custom_403'
handler500 = 'core.views.custom_500'
