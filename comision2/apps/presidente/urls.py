from django.urls import path, re_path
from apps.presidente import views
from django.contrib.auth.decorators import login_required
 

urlpatterns = [	 	


	re_path(r'^$', login_required(views.presidente),name='presidente'),
	re_path(r'^listae$', views.ListaE,name='ListaE'),


	re_path(r'^p_act_usu/$', views.ActUsuario.as_view(),name='p_act_usu'),
	re_path(r'^p_cam_usu/$', views.CambioUSER.as_view(),name='p_cam_usu'),
	re_path(r'^p_cam_pas/$', views.CambioPASS.as_view(),name='p_cam_pas'),

	re_path(r'^p_usuario_lis/$',login_required(views.DatosList.as_view()),name='p_usuario_lis'),
	re_path(r'^p_usuario_reg/$',views.DatosCreate.as_view(),name='p_usuario_reg'),
	re_path(r'^p_usuario_edi/(?P<pk>\d+)/$',login_required(views.DatosUpdate.as_view()),name='p_usuario_edi'),
	re_path(r'^p_usuario_eli/(?P<pk>\d+)/$',login_required(views.DatosDelete.as_view()),name='p_usuario_eli'),

	re_path(r'^p_usuario1_reg/$',views.UsuarioCreate.as_view(),name='p_usuario1_reg'),
	re_path(r'^p_usuario1_upd/(?P<pk>\d+)/$',views.UsuarioUpdate.as_view(),name='p_usuario1_upd'),
	re_path(r'^p_usuario1_del/(?P<pk>\d+)/$',login_required(views.UsuarioDelete.as_view()),name='p_usuario1_del'),



	re_path(r'^p_auth_lis/$',login_required(views.AuthList.as_view()),name='p_auth_lis'),
	re_path(r'^p_auth_bus/$',login_required(views.BuscarAuthList.as_view()),name='p_auth_bus'),


	re_path(r'^p_parcela_reg/$',login_required(views.ParcelaCreate.as_view()),name='p_parcela_reg'),
	re_path(r'^p_parcela_lis/$',login_required(views.ParcelaList.as_view()),name='p_parcela_lis'),
	re_path(r'^p_parcela_edi/(?P<pk>\d+)/$',login_required(views.ParcelaUpdate.as_view()),name='p_parcela_edi'),
	re_path(r'^p_parcela_eli/(?P<pk>\d+)/$',login_required(views.ParcelaDelete.as_view()),name='p_parcela_eli'),



	re_path(r'^p_canal_reg/$',login_required(views.CanalCreate.as_view()),name='p_canal_reg'),
	re_path(r'^p_canal_lis/$',login_required(views.CanalList.as_view()),name='p_canal_lis'),
	re_path(r'^p_canal_edi/(?P<pk>\d+)/$',login_required(views.CanalUpdate.as_view()),name='p_canal_edi'),
	re_path(r'^p_canal_eli/(?P<pk>\d+)/$',login_required(views.CanalDelete.as_view()),name='p_canal_eli'),


	re_path(r'^p_noticia_reg/$',login_required(views.NoticiaCreate.as_view()),name='p_noticia_reg'),
	re_path(r'^p_noticia_lis/$',login_required(views.NoticiaList.as_view()),name='p_noticia_lis'),
	re_path(r'^p_noticia_edi/(?P<pk>\d+)/$',login_required(views.NoticiaUpdate.as_view()),name='p_noticia_edi'),
	re_path(r'^p_noticia_eli/(?P<pk>\d+)/$',login_required(views.NoticiaDelete.as_view()),name='p_noticia_eli'),
 

	re_path(r'^p_caudal_reg/$',login_required(views.CaudalCreate.as_view()),name='p_caudal_reg'),
	re_path(r'^p_caudal_lis/$',login_required(views.CaudalList.as_view()),name='p_caudal_lis'),
	re_path(r'^p_caudal_eli/(?P<pk>\d+)/$',login_required(views.CaudalDelete.as_view()),name='p_caudal_eli'),

	re_path(r'^p_rep_caudal/$', login_required(views.RepCaudal.as_view()),name='p_rep_caudal'),
	re_path(r'^p_rep_caudal2/$', login_required(views.RepCaudal2.as_view()),name='p_rep_caudal2'),
	re_path(r'^p_rep_reparto/$', login_required(views.RepPeparto.as_view()),name='p_rep_reparto'),

	re_path(r'^pasambreg/$', login_required(views.AsambReg.as_view()),name='p_asamb_reg'),	
	re_path(r'^pasamblis/$', login_required(views.AsambLis.as_view()),name='p_asamb_lis'),
	re_path(r'^p_asamb_edi/?/$',login_required(views.AsambEdi.as_view()),name='p_asamb_edi'),
	re_path(r'^p_asamb_ini/?/$',login_required(views.AsambIni.as_view()),name='p_asamb_ini'),
	re_path(r'^p_hasis_est/?/$',login_required(views.HjaAsisEst.as_view()),name='p_hasis_est'),

	re_path(r'^p_asamb_del/?/$',login_required(views.AsmbDel.as_view()),name='p_asamb_del'),

	] 