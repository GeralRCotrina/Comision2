 

from django.contrib import admin
from django.urls import path, re_path, include

from django.conf.urls.static import static
from django.conf import settings

urlpatterns = [	
    re_path(r'^', include('apps.inicio.urls')),
    re_path(r'^usuario/', include('apps.usuario.urls'),name='usuario'),
    re_path(r'^canalero/', include('apps.canalero.urls')),
    re_path(r'^presidente/', include('apps.presidente.urls')),
    re_path(r'^tesorero/', include('apps.tesorero.urls')),
    re_path(r'^vocal/', include('apps.vocal.urls')),
   	path('admin/', admin.site.urls),
]+ static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
  