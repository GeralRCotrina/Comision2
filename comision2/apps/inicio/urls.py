
from django.urls import path, re_path
from apps.inicio import views
from django.contrib.auth.views import logout_then_login


urlpatterns = [
	re_path(r'^mylogin$', views.mylogin,name='mylogin'),
	re_path(r'^$', views.index,name='index'),
	re_path(r'^index', views.index,name='index'),
	re_path(r'^logout$',logout_then_login,name='logout'),
	re_path(r'^accounts/login/$', views.index,name='index'),
	re_path(r'^registrar-usuario/$',views.RegistrarUsuario.as_view(),name='RegistrarUsuario'),	
	
]
#re_path(r'^reporte2_pdf/$',views.Reporte2, name="reporte2_pdf"),
#re_path(r'^pdf_001/$',views.PDF_001.as_view(),name='pdf_001'),

