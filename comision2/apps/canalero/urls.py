from django.urls import path, re_path
from apps.canalero import views
from django.contrib.auth.decorators import login_required

urlpatterns = [
    re_path(r'^$', login_required(views.canalero),name='canalero'),



    re_path(r'^c_rep_print/?/$',login_required(views.ImprimirReparto.as_view()),name='c_rep_print'),
 
    re_path(r'^c_pdf_01/$',login_required(views.PDF_001.as_view()),name='c_pdf_01'), 
    re_path(r'^c_pdf_02/$',login_required(views.PDF_002.as_view()),name='c_pdf_02'),
    re_path(r'^c_pdf_03/$',login_required(views.PDF_001.as_view()),name='c_pdf_03'),

	re_path(r'^c_graf_rep/$',login_required(views.GrafRepC1.as_view()),name='c_graf_rep'),

	re_path(r'^c_rep_caudal/$', login_required(views.RepCaudal.as_view()),name='c_rep_caudal'),
	re_path(r'^c_rep_caudal2/$', login_required(views.RepCaudal2.as_view()),name='c_rep_caudal2'),
	re_path(r'^c_rep_reparto/$', login_required(views.RepPeparto.as_view()),name='c_rep_reparto'),

	re_path(r'^registrar-usuario/$',views.RegistrarUsuario.as_view(),name='c_RegistrarUsuario'),	

	re_path(r'^c_reparto_reg/$',login_required(views.RepartoCreate.as_view()),name='c_reparto_reg'),
	re_path(r'^c_reparto_lis/$',login_required(views.RepartoList.as_view()),name='c_reparto_lis'),
	re_path(r'^c_reparto_edi/(?P<pk>\d+)/$',login_required(views.RepartoUpdate.as_view()),name='c_reparto_edi'),
	re_path(r'^c_reparto_eli/(?P<pk>\d+)/$',login_required(views.RepartoDelete.as_view()),name='c_reparto_eli'),
	re_path(r'^c_reparto_lis_ord/?/$',login_required(views.SolicitudesPorReparto.as_view()),name='c_reparto_lis_ord'),


	re_path(r'^c_orden_apr/?/$',login_required(views.AprobarOrden.as_view()),name='c_orden_apr'),
	re_path(r'^c_orden_apr_lis/?/$',login_required(views.AprobarListaOrdenes.as_view()),name='c_orden_apr_lis'),
	re_path(r'^c_orden_hora/?/$',login_required(views.EstablecerHora.as_view()),name='c_orden_hora'),


	re_path(r'^c_multa_reg/$',login_required(views.MultaCreate.as_view()),name='c_multa_reg'),
	re_path(r'^c_multa_lis/$',login_required(views.MultaList.as_view()),name='c_multa_lis'),
	re_path(r'^c_multa_edi/(?P<pk>\d+)/$',login_required(views.MultaUpdate.as_view()),name='c_multa_edi'),
	re_path(r'^c_multa_eli/(?P<pk>\d+)/$',login_required(views.MultaDelete.as_view()),name='c_multa_eli'),

	re_path(r'^c_usuario_reg/$',login_required(views.UsuarioCreate.as_view()),name='c_usuario_reg'),
	re_path(r'^c_usuario_lis/$',login_required(views.UsuarioList.as_view()),name='c_usuario_lis'),
	re_path(r'^c_usuario_edi/(?P<pk>\d+)/$',login_required(views.UsuarioUpdate.as_view()),name='c_usuario_edi'),
	re_path(r'^c_usuario_eli/(?P<pk>\d+)/$',login_required(views.UsuarioDelete.as_view()),name='c_usuario_eli'),

	re_path(r'^c_noticia_reg/$',login_required(views.NoticiaCreate.as_view()),name='c_noticia_reg'),
	re_path(r'^c_noticia_lis/$',login_required(views.NoticiaList.as_view()),name='c_noticia_lis'),
	re_path(r'^c_noticia_edi/(?P<pk>\d+)/$',login_required(views.NoticiaUpdate.as_view()),name='c_noticia_edi'),
	re_path(r'^c_noticia_eli/(?P<pk>\d+)/$',login_required(views.NoticiaDelete.as_view()),name='c_noticia_eli'),

	re_path(r'^c_parcela_reg/$',login_required(views.ParcelaCreate.as_view()),name='c_parcela_reg'),
	re_path(r'^c_parcela_lis/$',login_required(views.ParcelaList.as_view()),name='c_parcela_lis'),
	re_path(r'^c_parcela_edi/(?P<pk>\d+)/$',login_required(views.ParcelaUpdate.as_view()),name='c_parcela_edi'),
	re_path(r'^c_parcela_eli/(?P<pk>\d+)/$',login_required(views.ParcelaDelete.as_view()),name='c_parcela_eli'),

	re_path(r'^c_canal_reg/$',login_required(views.CanalCreate.as_view()),name='c_canal_reg'),
	re_path(r'^c_canal_lis/$',login_required(views.CanalList.as_view()),name='c_canal_lis'),
	re_path(r'^c_canal_edi/(?P<pk>\d+)/$',login_required(views.CanalUpdate.as_view()),name='c_canal_edi'),
	re_path(r'^c_canal_eli/(?P<pk>\d+)/$',login_required(views.CanalDelete.as_view()),name='c_canal_eli'),

	re_path(r'^c_destajo_reg/$',login_required(views.DestajoCreate.as_view()),name='c_destajo_reg'),
	re_path(r'^c_destajo_lis/$',login_required(views.DestajoList.as_view()),name='c_destajo_lis'),
	re_path(r'^c_destajo_edi/(?P<pk>\d+)/$',login_required(views.DestajoUpdate.as_view()),name='c_destajo_edi'),
	re_path(r'^c_destajo_eli/(?P<pk>\d+)/$',login_required(views.DestajoDelete.as_view()),name='c_destajo_eli'),

	]



#re_path(r'^c_pdf_1/$',login_required(views.PDFPrueba.as_view()),name='c_pdf_1'), 
#re_path(r'^c_pdf_2/$',login_required(views.PDFPrueba2.as_view()),name='c_pdf_2'),
#re_path(r'^c_rep_rep/$',views.PDF_reparto.as_view(),name='c_rep_rep'),