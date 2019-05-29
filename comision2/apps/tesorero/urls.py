from django.urls import path, re_path
from apps.tesorero import views
from django.contrib.auth.decorators import login_required

urlpatterns = [
     re_path(r'^$', login_required(views.tesorero),name='tesorero'),
]
