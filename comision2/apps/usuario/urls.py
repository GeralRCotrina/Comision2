
from django.urls import path, re_path
from apps.usuario import views 
from django.contrib.auth.decorators import login_required


urlpatterns = [
	re_path(r'^$', login_required(views.usuario),name='usuario'), 

	re_path(r'^listar/$',login_required(views.UsuarioList.as_view()),name='listar'),
	re_path(r'^crear/$',login_required(views.UsuarioCreate.as_view()),name='crear'),
	re_path(r'^editar/(?P<pk>\d+)/$',login_required(views.UsuarioUpdate.as_view()),name='editar'),
	re_path(r'^eliminar/(?P<pk>\d+)/$',login_required(views.UsuarioDelete.as_view()),name='eliminar'),

	re_path(r'^u_orden_lis/$',login_required(views.OrdenList.as_view()),name='u_orden_lis'),
	re_path(r'^u_orden_reg/$',login_required(views.OrdenCreate.as_view()),name='u_orden_reg'),
#	re_path(r'^u_orden_edi/(?P<pk>\d+)/$',login_required(views.OrdenUpdate.as_view()),name='u_orden_edi'),
#	re_path(r'^u_orden_eli/(?P<pk>\d+)/$',login_required(views.OrdenDelete.as_view()),name='u_orden_eli'),

	re_path(r'^u_noticia_lis/$',login_required(views.NoticiaList.as_view()),name='u_noticia_lis'),

	re_path(r'^u_misparcelas_lis/?/$',login_required(views.FiltrarParcelas.as_view()),name='u_misparcelas_lis'),

	re_path(r'^u_reparto_lis/$',login_required(views.VerRepartos.as_view()),name='u_reparto_lis'),

	re_path(r'^u_orden_sol/$',login_required(views.SolOrdenList.as_view()),name='u_orden_sol'),
	re_path(r'^u_orden_eli/(?P<pk>\d+)/$',login_required(views.EliOrden.as_view()),name='u_orden_eli'),

	re_path(r'^u_mis_orden_lis/?/$',login_required(views.MisOrdenes.as_view()),name='u_mis_orden_lis'),

	re_path(r'^pruebas/$',login_required(views.Pruebas),name='pruebas'),


]




